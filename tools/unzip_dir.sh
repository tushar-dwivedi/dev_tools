#!/bin/bash

set -e

archive_url=$1
if [ "x$archive_url" == 'x' ];then
    echo "Usage: unzip_dir.sh <cdn colo url>"
    exit 1
fi

wget $archive_url

archive_file=$(basename $archive_url)
target_dir=$(echo $archive_file | sed -re 's/.zip$//g')

mkdir $target_dir
cd $target_dir
unzip ../$archive_file

for log_tar in $(find . -name log.tar*.gz); do
    ip=$(echo $log_tar | grep -Eo '/rksupport_[0-9.]+_' | grep -Eo '[0-9.]+')
    (mkdir logs_$ip && cd logs_$ip && tar -zxvf ../$log_tar)
done

pwd

rm ../$archive_file
