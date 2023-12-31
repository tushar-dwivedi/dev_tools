#!/bin/bash

. ./skip_commit/common/bodega_order_details.sh

echo "bodega_ips: ${bodega_ips}"

#IFS="," read -a myarray <<< ${bodega_ips}
IFS="," read -a bodega_ips_arr <<<$bodega_ips
echo "bodega_ips_arr: ${bodega_ips_arr[@]}"

for ip in "${bodega_ips_arr[@]}"; do
	echo $ip
	ssh-keyscan $ip >>~/.ssh/known_hosts

	ssh -i $pem_file ubuntu@$ip 'mkdir -p /home/ubuntu/tushar_bin/'

	#	for binary in "cqlproxy"
	# for binary in "cdc_restore_tool" "cdc_restore_tool_1" "cockroach_backup_tool" "cdc_data_publisher" "generate_cdc_data" "validate_cdc_data" "sqload"; do #	for binary in "dedup_compressor"
	for binary in "cdc_restore_tool" "cockroach_backup_tool" "cqlproxy"; do
		scp -i $pem_file ./src/go/bin/$binary ubuntu@$ip:/opt/rubrik/src/go/bin/ # /home/ubuntu/tushar_bin/      #       ~/tushar_bin/cockroach       # /usr/local/bin/cockroach
	done

	ssh -i $pem_file ubuntu@$ip "mkdir -p /opt/rubrik/conf/cdc_restore_tool/ /opt/rubrik/tools/callisto/"

	# Define the array of tuples (source and destination paths)
	declare -A paths=(
		["./deployment/ssh_keys/ubuntu.pem"]="/opt/rubrik/deployment/ssh_keys/ubuntu.pem"
#		["./deployment/ansible/gojq.yml"]="/opt/rubrik/deployment/ansible/gojq.yml"
		["./skip_commit/bin/gojq"]="/home/ubuntu/tushar_bin/gojq"
#		["./deployment/ansible/roles/gojq/defaults/main.yml"]="/opt/rubrik/deployment/ansible/roles/gojq/defaults/main.yml"
#		["./deployment/ansible/roles/gojq/tasks/main.yml"]="/opt/rubrik/deployment/ansible/roles/gojq/tasks/main.yml"
		["./deployment/ansible/cockroachdb_restore.yml"]="/opt/rubrik/deployment/ansible/cockroachdb_restore.yml"
		["./deployment/ansible/roles/cqlproxy_migration/tasks/setup_publisher.yml"]="/opt/rubrik/deployment/ansible/roles/cqlproxy_migration/tasks/setup_publisher.yml"
		["./deployment/ansible/roles/cqlproxy_migration/tasks/stop_publisher.yml"]="/opt/rubrik/deployment/ansible/roles/cqlproxy_migration/tasks/stop_publisher.yml"
#		["./deployment/ansible/roles/cqlproxy_migration/tasks/dedup_compression.yml"]="/opt/rubrik/deployment/ansible/roles/cqlproxy_migration/tasks/dedup_compression.yml"
		["./deployment/ansible/roles/cqlproxy_migration/tasks/cdc_restore.yml"]="/opt/rubrik/deployment/ansible/roles/cqlproxy_migration/tasks/cdc_restore.yml"
		["./deployment/ansible/roles/cqlproxy_migration/tasks/stop_nginx.yml"]="/opt/rubrik/deployment/ansible/roles/cqlproxy_migration/tasks/stop_nginx.yml"
		["./src/scripts/dev/cdc_data_publisher.sh"]="/opt/rubrik/src/scripts/dev/cdc_data_publisher.sh"
		["./src/py/cockroachdb/start_cmd.py"]="/opt/rubrik/src/py/cockroachdb/start_cmd.py"
		["./skip_commit/check_logs.sh"]="~/check_logs.sh"
		["./skip_commit/log_patterns.txt"]="~/log_patterns.txt"
		["./src/scripts/callisto/CompareCrdbSnapshots.sh"]="/opt/rubrik/src/scripts/callisto/CompareCrdbSnapshots.sh"
		["./conf/cdc_restore_tool/config.json"]="/opt/rubrik/conf/cdc_restore_tool/config.json"
		["./tools/callisto/cdc/cdc_restore_tool/restore_monitor.sh"]="/opt/rubrik/tools/callisto/restore_monitor.sh"
		["./skip_commit/bin/nethogs"]="/opt/rubrik/src/go/bin/"
	)

	# Loop through the array of tuples and copy files from source to destination
	for source_path in "${!paths[@]}"; do
		destination_path="${paths[$source_path]}"

		# Copy the file from source to destination
		scp -i $pem_file "$source_path" "ubuntu@$ip:$destination_path"

		# Check if the copy was successful
		#if [[ $? -eq 0 ]]; then
		#  echo "File copied successfully: $source_path -> $destination_path"
		#else
		#  echo "Failed to copy file: $source_path"
		#fi
	done

done
