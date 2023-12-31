#!/bin/bash

set -x

if [ -f ~/verify_restore/restore_utils.sh ]; then
  . ~/verify_restore/restore_utils.sh
else
  . ./skip_commit/verify_cdc/restore_run/remote_scripts/restore_utils.sh
fi

#UffService blocker bug mitigation

#/opt/rubrik/deployment/cluster.sh localcluster exec all 'mkdir /home/ubuntu/rules_backup; cp -rf /var/lib/rubrik/iptables/* /home/ubuntu/rules_backup/';
#/opt/rubrik/deployment/cluster.sh localcluster exec all 'bash -c "grep -v UffService /var/lib/rubrik/iptables/rules.v4 > /tmp/rules.v4; cat /tmp/rules.v4 > /var/lib/rubrik/iptables/rules.v4"'
#/opt/rubrik/deployment/cluster.sh localcluster exec all 'bash -c "grep -v UffService /var/lib/rubrik/iptables/rules.v6 > /tmp/rules.v6; cat /tmp/rules.v6 > /var/lib/rubrik/iptables/rules.v6"'

output=$(sudo -u ubuntu /opt/rubrik/src/scripts/dev/rubrik_tool.py get_config callisto validateCDCDataFrequency)
if [[ $output != "0" ]]; then
  sudo -u ubuntu /opt/rubrik/src/scripts/dev/rubrik_tool.py update_config callisto validateCDCDataFrequency 0
fi

sudo -u ubuntu /opt/rubrik/src/scripts/dev/rubrik_tool.py get_config callisto validateCDCDataFrequency

sudo -u ubuntu /opt/rubrik/src/scripts/dev/rubrik_tool.py update_feature_toggle enableCDCDataPublisher false
return_value=$?

if [[ $return_value != 0 ]]; then
  echo "An error occurred while executing the command(enableCDCDataPublisher). Exiting the script."
  exit 1
fi

sudo -u ubuntu /opt/rubrik/src/scripts/dev/rubrik_tool.py update_config callisto cockroachBackupJobPeriodMinutes 4800
return_value=$?
if [[ $return_value != 0 ]]; then
  echo "An error occurred while executing the command(cockroachBackupJobPeriodMinutes). Exiting the script."
  exit 1
fi

DisableCDC

log_milestone "disabled CDC before starting"

/opt/rubrik/deployment/cluster.sh localcluster exec all 'ls -lh /mnt/wwn-f*/internal/cass*/cdc_data'

/opt/rubrik/deployment/cluster.sh localcluster exec all 'ls -lh /mnt/wwn-f*/internal/cass*/'

/opt/rubrik/deployment/cluster.sh localcluster exec all 'sudo systemctl stop cqlproxy'
return_value=$?
if [[ $return_value != 0 ]]; then
  echo "An error occurred while executing the command 'sudo systemctl stop cqlproxy'. Exiting the script."
  exit 1
fi

/opt/rubrik/deployment/cluster.sh localcluster exec all 'sudo systemctl stop rk-job-fetcher.service'
return_value=$?
if [[ $return_value != 0 ]]; then
  echo "An error occurred while executing the command 'sudo systemctl stop rk-job-fetcher.service'. Exiting the script."
  exit 1
fi

/opt/rubrik/deployment/cluster.sh localcluster exec all 'sudo systemctl stop cockroachdb'
return_value=$?

if [[ $return_value != 0 ]]; then
  echo "An error occurred while executing the command. Exiting the script."
  exit 1
fi

/opt/rubrik/deployment/cluster.sh localcluster exec all 'sudo chattr -i -RV /mnt/wwn-f*/internal/cass*/cdc_data/'
/opt/rubrik/deployment/cluster.sh localcluster exec all 'sudo rm -rf /mnt/wwn-*/internal/cass*/cdc_data'
return_value=$?
if [[ $return_value != 0 ]]; then
  echo "An error occurred while executing the command. Exiting the script."
  exit 1
fi

/opt/rubrik/deployment/cluster.sh localcluster exec all 'sudo chattr -i -RV /mnt/wwn-f*/internal/cass*/intermediate_cdc_data/'
/opt/rubrik/deployment/cluster.sh localcluster exec all 'sudo rm -rf /mnt/wwn-*/internal/cass*/intermediate_cdc_data'
return_value=$?
if [[ $return_value != 0 ]]; then
  echo "An error occurred while executing the command. Exiting the script."
  exit 1
fi

/opt/rubrik/deployment/cluster.sh localcluster exec all 'sudo rm -rf /mnt/wwn-f*/internal/cass*/*BACK_UP_COCKROACH_GLOBAL*'
return_value=$?
if [[ $return_value != 0 ]]; then
  echo "An error occurred while executing the command. Exiting the script."
  exit 1
fi

/opt/rubrik/deployment/cluster.sh localcluster exec all 'sudo rm -rf /var/log/cockroach_backup_tool/*'

/opt/rubrik/deployment/cluster.sh localcluster exec all 'mkdir -p /var/log/cockroach_backup_tool/cdc_restore_tool'
/opt/rubrik/deployment/cluster.sh localcluster exec all 'chown -R rkcluster:rkcluster /var/log/cockroach_backup_tool/'

/opt/rubrik/deployment/cluster.sh localcluster exec all 'sudo rm -rf /var/log/cockroachdb/*'

return_value=$?
if [[ $return_value != 0 ]]; then
  echo "An error occurred while executing the command. Exiting the script."
  exit 1
fi

/opt/rubrik/deployment/cluster.sh localcluster exec all 'rm -rf /var/lib/cockroachdb/kronos/*'
/opt/rubrik/deployment/cluster.sh localcluster exec all 'sudo rm -rf /var/log/job-fetcher/*'

/opt/rubrik/deployment/cluster.sh localcluster exec all 'sudo systemctl start cockroachdb.service'
return_value=$?

if [[ $return_value != 0 ]]; then
  echo "An error occurred while executing the command. Exiting the script."
  exit 1
fi

sleep 15

# /opt/rubrik/deployment/cluster.sh localcluster  exec all 'sudo rm -rf /var/log/job-fetcher/*'
# return_value=$?
# if [[ $return_value != 0 ]]; then
#     echo "An error occurred while executing the command. Exiting the script."
#     exit 1
# fi

/opt/rubrik/deployment/cluster.sh localcluster exec all 'sudo rm /run/rubrik/cdc_publisher/scanner_checkpoint.json'

/opt/rubrik/deployment/cluster.sh localcluster exec all 'sudo rm -rf /var/log/cdc_data_publisher/*'
/opt/rubrik/deployment/cluster.sh localcluster exec all 'sudo rm -rf /var/log/cqlproxy/*'

/opt/rubrik/deployment/cluster.sh localcluster exec all 'sudo systemctl start cqlproxy'
return_value=$?
if [[ $return_value != 0 ]]; then
  echo "An error occurred while executing 'sudo systemctl start cqlproxy'. Exiting the script."
  exit 1
fi

/opt/rubrik/deployment/cluster.sh localcluster exec all 'sudo systemctl start rk-job-fetcher.service'

/opt/rubrik/deployment/cluster.sh localcluster exec all "sdservice.sh '*' start"
return_value=$?
if [[ $return_value != 0 ]]; then
  exit 1
fi

log_milestone "start all services"

sleep 120

sudo /opt/rubrik/src/scripts/cockroachdb/rkcockroach sql -e "TRUNCATE sd.node_cdc_data_chunks"
return_value=$?
if [[ $return_value != 0 ]]; then
  echo "An error occurred while executing 'rkcockroach sql -e \"TRUNCATE sd.node_cdc_data_chunks\"'. Exiting the script."
fi

sudo /opt/rubrik/src/scripts/cockroachdb/rkcockroach sql -e "TRUNCATE sd.cdc_data_publishing_jobs"
return_value=$?
if [[ $return_value != 0 ]]; then
  echo "An error occurred while executing 'rkcockroach sql -e \"TRUNCATE sd.cdc_data_publishing_jobs\"'. Exiting the script."
fi

sudo /opt/rubrik/src/scripts/cockroachdb/rkcockroach sql -e "TRUNCATE sd.cdc_data_publishing_progress_reports"
return_value=$?
if [[ $return_value != 0 ]]; then
  echo "An error occurred while executing 'rkcockroach sql -e \"TRUNCATE sd.cdc_data_publishing_progress_reports\"'. Exiting the script."
fi

sudo /opt/rubrik/src/scripts/cockroachdb/rkcockroach sql -e "TRUNCATE sd.files_perf_test_only CASCADE"
return_value=$?
if [[ $return_value != 0 ]]; then
  echo "An error occurred while executing 'rkcockroach sql -e \"TRUNCATE sd.files_perf_test_only CASCADE\"'. Exiting the script."
fi

sudo /opt/rubrik/src/scripts/cockroachdb/rkcockroach sql -e "TRUNCATE sd.files_perf_test_only__static CASCADE"
return_value=$?
if [[ $return_value != 0 ]]; then
  echo "An error occurred while executing 'rkcockroach sql -e \"TRUNCATE sd.files_perf_test_only__static CASCADE\"'. Exiting the script."
fi

sudo /opt/rubrik/src/scripts/cockroachdb/rkcockroach sql -e "DROP DATABASE sd_restore CASCADE"

log_milestone "truncated restore metadata tables & dropped sd_restore DB"

sudo /opt/rubrik/src/scripts/cockroachdb/rkcockroach sql -e "ALTER DATABASE sd CONFIGURE ZONE USING gc.ttlseconds = 6000"
sudo /opt/rubrik/src/scripts/cockroachdb/rkcockroach sql -e "SHOW ZONE CONFIGURATION FROM database sd"

# enable backup jobs
# /usr/bin/cqlsh -k sd -e "update job_instance set skip=false where job_id='BACK_UP_COCKROACH_GLOBAL'"
# /usr/bin/cqlsh -k sd -e "select job_id, instance_id, status, skip, is_disabled from job_instance where job_id='BACK_UP_COCKROACH_GLOBAL'"

# log_milestone "enabled BACK_UP_COCKROACH_GLOBAL"

sleep 10

set +x
