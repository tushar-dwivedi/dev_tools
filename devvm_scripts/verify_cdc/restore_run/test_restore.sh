#!/bin/bash

set -x

. ./skip_commit/common/bodega_order_details.sh
. ./skip_commit/common/copy_remote_scripts.sh
. ./skip_commit/verify_cdc/restore_run/remote_scripts/restore_utils.sh

remote_node_script_dir=~/verify_restore/

copy_all_remote_scripts

first_node_ip=${bodega_ips_arr[0]}

echo "running commands on : $first_node_ip"

ssh -i $pem_file ubuntu@$first_node_ip "bash -s" <./skip_commit/verify_cdc/restore_run/cleanup_previous_run.sh
return_value=$?
if [[ $return_value != 0 ]]; then
    echo "An error occurred while running cleanup_previous_run. Exiting the script."
    exit 1
fi

# Add some data with CDC disabled
# BAZEL_USE_REMOTE_WORKERS=0 python3 -m jedi.tools.sdt_runner --bodega_sid ${bodega_order_id} --test_target //jedi/e2e/callisto:crdb_load_test -- -k "test_perf_files" --crdb_load_duration "30m" --crdb_skip_cdc_enable

ssh -i $pem_file ubuntu@$first_node_ip "bash -s" <./skip_commit/verify_cdc/restore_run/take_first_backup.sh
return_value=$?
if [[ $return_value != 0 ]]; then
    echo "An error occurred while running take_first_backup. Exiting the script."
    exit 1
fi

# Add some data with CDC enabled
# BAZEL_USE_REMOTE_WORKERS=0
# python3 -m jedi.tools.sdt_runner --bodega_sid ${bodega_order_id} --test_target //jedi/e2e/callisto:crdb_load_test -- -k "test_perf_files" --crdb_load_duration "30m" --crdb_skip_cdc_enable
python3 -m jedi.tools.sdt_runner --test_target //jedi/e2e/callisto:crdb_load_test --bodega_sid iqjogb-ppj6jta -- -k "test_custom_perf" --crdb_populate_rows 250000 --crdb_load_duration 15m --crdb_load_name files --crdb_load_type cqlproxy
sleep 300

ssh -i $pem_file ubuntu@$first_node_ip "bash -s" <./skip_commit/verify_cdc/restore_run/stop_cdc_and_take_second_backup.sh

ssh -i $pem_file ubuntu@$first_node_ip "bash -s" <./skip_commit/verify_cdc/restore_run/capture_stats.sh
if [ $? -eq 0 ]; then
    echo "capture_stats.sh executed successfully with no errors."
else
    echo "capture_stats.sh exited with an error (exit status 1 or higher)."
    exit 1
    # Take appropriate action here
fi

bash ./skip_commit/verify_cdc/restore_debug/start_restore_debug.sh "files_perf_test_only"
bash ./skip_commit/verify_cdc/restore_debug/start_restore_debug.sh "files_perf_test_only__static"

echo -e '\a'

set +x
