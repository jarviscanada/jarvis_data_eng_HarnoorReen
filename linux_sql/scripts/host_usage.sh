#!/bin/bash

#This script is used to collect machine usage information, usually the script is exeuted multiple times during the day using crontab
#As a pre-requisite the computer configuration should be already loaded in host_info table.

#get the below parameters as arguments for this script
psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

#validate if all 5 arguments are passed

if [ "$#" -ne 5 ]; then
    echo "Illegal number of parameters"
    exit 1
fi

# save machine statistics to a variable
vmstat_mb=$(vmstat --unit M)

#Get the name of the hostmachine in a variable
hostname=$(hostname -f)

#Get the memory free info from vmstat command
memory_free=$(echo "$vmstat_mb" | awk '{print $4}'| tail -n1 | xargs)

#Get cpu idle info from vmstat command
cpu_idle=$(echo "$vmstat_mb" |awk '{print $15}'| tail -1 | xargs)

#Get cpu kernal from vmstat command
cpu_kernel=$(echo "$vmstat_mb" | awk '{print $14}'| tail -1 | xargs)

#Get current number of I/O Operations in progress from Vmstat command
disk_io=$(vmstat -d | awk '{print $10}' | tail -1 | xargs)

#Get disk available from the system with vmstat command
disk_available=$(df -BM | awk '{print $4 - "M"}' | tail -1 | xargs)

#Current timestamp in a specified format.
timestamp=$(date +'%Y-%m-%d %T')


#Query to fetch the host_id from host_info table using hostname as input
host_id="(SELECT id FROM host_info WHERE hostname='$hostname')";


#consturct the insert statement using the variables to insert into host_usage table
insert_stmt="INSERT INTO host_usage (timestamp, host_id, memory_free, cpu_idle, cpu_kernel, disk_io, disk_available)
 VALUES('$timestamp' , $host_id, '$memory_free', '$cpu_idle', '$cpu_kernel', '$disk_io', '$disk_available')";

 #export pgpassword to avoid password prompt
export PGPASSWORD=$psql_password

#connect to psql database using input details adn execute insert command
psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -c "$insert_stmt"

exit $?