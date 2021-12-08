#!/bin/bash

#automation.sh

myname="Aditya"
s3_bucket="s3://upgrad-aditya/"

#UPDATES THE PACKAGES
sudo apt update -y

#ENSURE HTTP APACHE SERVER IS INSTALLED
dpkg -s apache2  &> /dev/null

if [ $? -eq 0 ]; then
    echo "Apache2 is installed!"
else
    echo "Apache is NOT installed!"
    sudo apt install apache2
fi

#ENSURE THAT HTTP APACHE SERVICE IS RUNNING

servstat=$(service apache2 status)

if [[ $servstat == "active (running)" ]]; then
  echo "Apache SERVICE is running"
else
  echo "Apache SERVICE is NOT running. Starting it..."
  sudo systemctl start apache2

fi

#ENSURE THAT HTTP APACHE SERVICE IS ENABLED

isenabled=$(systemctl is-enabled apache2)
if [[ $isenabled == "enabled" ]]; then
echo "Apache service is enabled."
else
echo "Apache service is disabled. Enabling it..."
sudo systemctl enable apache2
fi

#ARCHIVING LOGS TO S3

timestamp=$(date '+%d%m%Y-%H%M%S')
tar_filename="/tmp/"${myname}"-httpd-logs-"${timestamp}".tar"
echo $tar_filename
tar -cvf $tar_filename --absolute-names /var/log/apache2/*.log
aws s3 cp $tar_filename $s3_bucket

