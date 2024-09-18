# Linux Cluster Monitoring Agent

# Introduction
The scope of this Linux cluster monitoring project is to collect machine hardware specifications and automate the storage of resource usage data into a PostgreSQL database. This data enables the Jarvis Linux Cluster Administration (LCA) team to monitor server performance, conduct data analytics, and manage the servers efficiently. The project is designed to be deployable on any Linux host machine to gather real-time data. The primary users of this project are system administrators and IT professionals responsible for server management. Key technologies used in this project include Git, GitHub, Docker, Bash scripts, PostgreSQL, and Rocky Linux.

# Quick Start

### Create new container and docker instance
```bash
./scripts/psql_docker.sh create [database_name] [database_password]
  ```
'create' makes a new instance with the given username and password for the instance \
After creation:
`./psql_docker.sh start` and `./psql_docker.sh stop` to start and stop the container.

### Create new PostgreSQL tables 
```bash
psql -h localhost -U postgres -d [database_name] -f sql/ddl.sql
```
After execution two tables `host_info` and `host_usage` are created

### Insert hardware specifications data
```bash
./scripts/host_info.sh localhost 5432 [database_name] postgres [database_password]
```
### Insert hardware usage data
```bash
./scripts/host_usage.sh localhost 5432 [database_name] postgres [database_password]
```
### Automation of Usage Data Entry
Run `crontab -e` to open the cron editor interface
```bash
* * * * * bash <home_location>/scripts/host_usage.sh localhost 5432 [db_name] [postgres] [password] > /tmp/host_usage.log
```
This automates the `host_usage.sh` script to run every minute.