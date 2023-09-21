// Copyright 2017 Rubrik, Inc.

package cli

import (
	"context"
	"database/sql"
	"fmt"
	"net/http"
	_ "net/http/pprof" // For profiling http endpoints
	"os"
	"time"

	instsql "github.com/ExpansiveWorlds/instrumentedsql"
	instsqlot "github.com/ExpansiveWorlds/instrumentedsql/opentracing"
	"github.com/opentracing/opentracing-go"
	zipkin "github.com/openzipkin-contrib/zipkin-go-opentracing"
	"github.com/pkg/errors"

	"rubrik/config"
	"rubrik/cqlproxy/cdmserver"
	cqlproxyConfig "rubrik/cqlproxy/config"
	"rubrik/cqlproxy/executor"
	"rubrik/cqlproxy/sch"
	"rubrik/cqlproxy/telemetry"
	"rubrik/pqwrapper"
	"rubrik/util/crdbutil"
	"rubrik/util/debug/profiledump"
	"rubrik/util/flag"
	"rubrik/util/log"
)

const (
	flagUpdateAddr                  = "localhost:27578"
	zipkinAddr                      = "http://localhost:9411/api/v1/spans"
	defaultTelemetryFlag            = false
	defaultTelemetryHistoBucketSize = 1000
	defaultTelemetryHistoAutoResize = true
	defaultHdrHistSigDigits         = 3
	defaultUseHdrHistForTimers      = false
)

var rootFlagSet = flag.CommandLine
var testModeAsserted = rootFlagSet.Bool(
	"test_mode",
	false,
	"Disable functions that aren't necessary for testing in dev-box.\n"+
		"This should never be used in CDM clusters.")
var jsonSchemaFlagPath = rootFlagSet.String(
	"json_schema",
	"",
	"JSON schema file path.")
var zipkinTracingEnabled = rootFlagSet.RegisterOnlineBool(
	"zipkin_tracing_enabled",
	false,
	"Whether request tracing is enabled.",
	zipkinTracingUpdate,
)
var tracingSamplingRate = rootFlagSet.Int64(
	"tracing_sampling_rate",
	10,
	"Trace 1 in this many requests.",
)
var dataIPFlag = rootFlagSet.String(
	"host_ip",
	"",
	"node's data IP we are hosted on.")

func initHTTPPprof(ctx context.Context) {
	// src/scripts/dev/rksupport.sh uses this to generate support-bundle
	pprofAddr := fmt.Sprintf("localhost:%d", *cqlproxyConfig.HTTPPprofPortFlagVal)
	log.Infof(ctx, "Starting http pprof. To see debug info go to http://%s/debug/pprof", pprofAddr)
	go func() {
		if err := http.ListenAndServe(pprofAddr, nil); err != nil {
			log.Fatal(ctx, "HTTP pprof ListenAndServer error", err)
		}
	}()
}

var zipkinCollector zipkin.Collector

func zipkinTracingUpdate(v string) error {
	switch v {
	case "true":
		if zipkinCollector != nil {
			zipkinCollector.Close()
			zipkinCollector = nil
		}
		var err error
		if zipkinCollector, err = zipkin.NewHTTPCollector(zipkinAddr); err != nil {
			return err
		}
		var tracer opentracing.Tracer
		if tracer, err = zipkin.NewTracer(
			zipkin.NewRecorder(zipkinCollector, false, "127.0.0.1:0", "cqlproxy"),
			zipkin.WithSampler(zipkin.ModuloSampler(uint64(*tracingSamplingRate))),
		); err != nil {
			return err
		}
		opentracing.SetGlobalTracer(tracer)
	case "false":
		if zipkinCollector != nil {
			zipkinCollector.Close()
			zipkinCollector = nil
		}
		opentracing.SetGlobalTracer(opentracing.NoopTracer{})
	default:
		return errors.Errorf(
			"true and false are the only valid values for zipkin_tracing_enabled"+
				", not %s",
			v,
		)
	}
	return nil
}

type teleMetryConfig struct {
	enable                bool
	histoBucketSize       int
	histoAutoResize       bool
	hdrHistogramSigDigits int
	useHdrHistForTimers   bool
}

func getTelemetryLocalConfig(ctx context.Context) *teleMetryConfig {
	tConfig := &teleMetryConfig{}
	namespace := "callisto"

	if !*testModeAsserted {
		config.LoadConfigWithDefault(
			ctx,
			namespace,
			"cqlproxyTelemetry",
			&tConfig.enable,
			defaultTelemetryFlag)

		if !tConfig.enable {
			return tConfig
		}

		config.LoadConfigWithDefault(
			ctx,
			namespace,
			"cqlproxyHistogramReservoirSize",
			&tConfig.histoBucketSize,
			defaultTelemetryHistoBucketSize)
		config.LoadConfigWithDefault(
			ctx,
			namespace,
			"cqlproxyHistogramAutoResize",
			&tConfig.histoAutoResize,
			defaultTelemetryHistoAutoResize)
		config.LoadConfigWithDefault(
			ctx,
			namespace,
			"cqlproxyHdrHistogramSignificantDigits",
			&tConfig.hdrHistogramSigDigits,
			defaultHdrHistSigDigits)
		config.LoadConfigWithDefault(
			ctx,
			namespace,
			"cqlproxyUseHdrHistogramForTimers",
			&tConfig.useHdrHistForTimers,
			defaultUseHdrHistForTimers)
	}
	return tConfig
}

func setTelemetryConfig(config *teleMetryConfig) {
	telemetry.SetHistogramReservoirSize(config.histoBucketSize)
	telemetry.SetHistogramAutoResize(config.histoAutoResize)
	telemetry.SetHdrHistogramSignificantValueDigits(config.hdrHistogramSigDigits)
	telemetry.SetUseHdrHistogramForTimers(config.useHdrHistForTimers)
}

// OpenDBSession opens sql DB session. Is also used by metadata migrator
func OpenDBSession(
	ctx context.Context,
	dbURLParams *crdbutil.DBURLParams,
	enableTracing bool,
) (*sql.DB, error) {
	url, err := dbURLParams.URL()

	checkError(ctx, err, "Generate CockroachDB connection URL")

	sqlLogger := instsql.LoggerFunc(func(ctx context.Context, msg string, keyvals ...interface{}) {
		if log.V(4) {
			if ctx == nil {
				log.Info(context.Background(), "got nil ctx")
				return
			}
			log.Infof(ctx, "instsql msg: %s keyVals: %v", msg, keyvals)
		}
	})
	driver :=
		instsql.WrapDriver(
			pqwrapper.NewDriver(), instsql.WithLogger(sqlLogger))
	if enableTracing {
		driver = instsql.WrapDriver(
			driver,
			// This works off of opentracing.GlobalTracer()
			instsql.WithTracer(instsqlot.NewTracer()))
	}
	sql.Register("instrumented-postgres", driver)
	log.Info(ctx, "CockroachDB url:", url.String())
	return sql.Open("instrumented-postgres", url.String())
}

// Main is the entry point for cql proxy service.
func Main() {
	defaults := crdbutil.DefaultDBURLParams()
	// Need rk_owner for TRUNCATE to work.
	defaults.User = crdbutil.RkOwner
	dbURLParams := crdbutil.DeclareCockroachDBURLFlagsWithDefaults(
		rootFlagSet.FlagSet,
		defaults,
	)
	dbURLParams.ApplicationName = "cqlproxy"
	ctx := log.WithLogTag(context.Background(), "main", nil)
	defer log.Flush()

	if err := flag.Parse(); err != nil {
		log.Fatalf(ctx, "Could not parse flags because of error: %v", err)
	}

	log.Infof(ctx, "Starting cqlproxy with arguments: %s", os.Args)

	tConfig := getTelemetryLocalConfig(ctx)
	if tConfig.enable {
		setTelemetryConfig(tConfig)
	}

	log.Infof(ctx, "Telemetry flags: %+v", tConfig)
	initHTTPPprof(ctx)
	if err := zipkinTracingUpdate(fmt.Sprint(zipkinTracingEnabled.Get())); err != nil {
		log.Errorf(ctx, "Zipkin tracing Initialization error: %v", err)
	}

	runtimeMonitor := profiledump.NewRuntimeStatsMonitor(&profiledump.MonitorConfig{
		ProfileDumpDir:          "/var/log/cqlproxy/profiledumps",
		MaxCombinedFileSize:     2 * 1024 * 1024 * 1024, // 2 GB
		MaxFileLifetime:         30 * 24 * time.Hour,    // 30 days
		StatsPollInterval:       10 * time.Second,
		EnableGoroutineDump:     true,
		GoroutinesDumpThreshold: 20,
		EnableGoHeapDump:        true,
		TotalHeapDumpThreshold:  4 * 1024 * 1024 * 1024, // 4 GB,
	})
	err := runtimeMonitor.StartMonitoringSamples(ctx)
	if err != nil {
		log.Warningf(ctx, "started CQL-Proxy without profile dump, err:%v", err)
	}

	schCatalogConfig := sch.DefaultCatalogConfig()
	if !*testModeAsserted {
		schCatalogConfig = sch.LoadCatalogConfig(ctx)
	}
	log.Infof(ctx, "SChStack catalog-config: %+v", schCatalogConfig)

	db := GetDBSessionWithNMaxIdleConns(ctx, dbURLParams, true, 100)
	defer db.Close()

	if err := rootFlagSet.RegisterCallback(
		"verbosity",
		func(s string) error { log.Info(ctx, "Verbosity updated to ", s); return nil },
	); err != nil {
		log.Warningf(ctx, "could not enable online verbosity update due to err: ", err)
	}
	go func() {
		log.Info(
			ctx,
			"Starting online flag update handler on: ",
			flagUpdateAddr,
		)
		if err := http.ListenAndServe(flagUpdateAddr, rootFlagSet); err != nil {
			log.Error(ctx, err)
		}
	}()

	stopCh := make(chan struct{})
	cdmserver.StartProxyServer(
		ctx,
		executor.NewCockroachDBExecGetter(db),
		&cdmserver.ServerCfg{
			EnableTelemetry: tConfig.enable,
			RunningTestMode: *testModeAsserted,
			HostIP:          *dataIPFlag,
			Port:            *cqlproxyConfig.CqlPortFlag,
			SchemaFilePath:  *jsonSchemaFlagPath,
		},
		schCatalogConfig,
		sch.DefaultStackLoader,
		stopCh)
}

// GetDBSessionWithNMaxIdleConns returns DB session after setting Max idle connections to N
func GetDBSessionWithNMaxIdleConns(
	ctx context.Context,
	dbURLParams *crdbutil.DBURLParams,
	enableTracing bool,
	maxIdleConns int) *sql.DB {
	db, err := OpenDBSession(ctx, dbURLParams, enableTracing)
	checkError(ctx, err, "DB open")
	db.SetMaxIdleConns(maxIdleConns)
	return db
}

func checkError(ctx context.Context, err error, msgs ...string) {
	if err != nil {
		log.FatalfDepth(ctx, 1, "", msgs, " Fatal error: ", err)
	}
}
