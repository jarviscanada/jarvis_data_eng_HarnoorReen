#!/bin/bash

#This script is used to capture computer configuration and insert it into table host_info.
#This script is to run only once in a computer that needs to be monitored

#Script takes 5 parameters as input that will be used for logging into database.
psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

#validata if all 5 parameters are passed
if [ "$#" -ne 5 ]; then
    echo "Illegal number of parameters"
    exit 1
fi

#Name of the host machine
hostname=$(hostname -f)

#Number of CPUs derived from lscpu command
cpu_number=$(lscpu  | egrep "^CPU\(s\):" | awk '{print $2}' | xargs)

#Architecture info derived from lscpu command
cpu_architecture=$(lscpu | grep Architecture | awk '{print $2}' | xargs)

#CPU model taken from lscpu command
cpu_model=$(lscpu | grep "Model name" | awk -F: '{print $2}' | xargs)

#Memory Cache taken from lscpu command
l2_cache=$(lscpu | grep "L2 cache" | awk -F : '{print $2 - "K"}' | xargs)

#CPU MHz taken from cpuinfo
cpu_mhz=$(cat /proc/cpuinfo | egrep "^cpu MHz" | head -n 1 | awk '{print $4}' | xargs)

#Currnt system time in specified format
timestamp=$(date +'%Y-%m-%d %T')

#Total memory using free command
total_mem=$(free -h | awk '/Mem/{print $2 - "G"}')


#Construct Insert statement using variables
insert_stmt="INSERT INTO host_info ( hostname, cpu_number, cpu_architecture, cpu_model, cpu_mhz, "l2_cache", "timestamp", "total_mem")
VALUES( '$hostname', "$cpu_number", '$cpu_architecture', '$cpu_model','$cpu_mhz', "$l2_cache", '$timestamp', "$total_mem")"

#Export password to void password prompt
export PGPASSWORD=$psql_password

#Connect to database and execcute the insert statement
psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -c "$insert_stmt"


exit $?