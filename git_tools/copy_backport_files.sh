#!/bin/bash

# Path to the file containing file paths
#file_with_paths="file_with_paths.txt"
file_with_paths="/tmp/files_changed_between_branches_changed_files.tmp"


# Remote server details
remote_user="ubuntu"
remote_server="dev_vm"
remote_path="/home/ubuntu/Documents/projects/callisto/sdmain"

# Local server details
local_path="/home/tushar/Documents/projects/sdmain"

# Create local directory if it doesn't exist
#mkdir -p $local_path

# Loop through each line in the file
while IFS= read -r line; do
    # Copy the file from the remote server to the local server
    mkdir -p $local_path/$(dirname $line)
    scp $remote_user@$remote_server:$remote_path/$line $local_path/$line
done < "$file_with_paths"

# Paths to be scp-ed
#paths_to_scp=(
#    "src/go/src/rubrik/callisto/cdc/publisher"
#    "src/go/src/rubrik/callisto/config"
#    "src/go/src/rubrik/callisto/election"
#)

# Loop through each path in the array
#for path in "${paths_to_scp[@]}"; do
#    # Create the directory structure locally
#    local_dir_path="$local_path/$(dirname "$path")"
#    mkdir -p "$local_dir_path"
#
#    # Copy the file from the remote server to the local server
#    scp -r $remote_user@$remote_server:$remote_path/$path $local_dir_path/
#done