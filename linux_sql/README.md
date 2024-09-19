# Linux Cluster Monitoring Agent

# Introduction
The scope of this Linux cluster monitoring project is to collect machine hardware specifications and automate the storage of resource usage data into a PostgreSQL database. This data enables the Jarvis Linux Cluster Administration (LCA) team to monitor server performance, conduct data analytics, and manage the servers efficiently. The project is designed to be deployable on any Linux host machine to gather real-time data. The primary users of this project are system administrators and IT professionals responsible for server management.\
Key technologies used: in this project include 
- Git, GitHub 
- Docker
- Bash scripts
- PostgreSQL
- Rocky Linux

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

# Implementation
- First, create a Docker container on the host system to run the PostgreSQL database instance.
- Once the instance is running, execute the SQL file to create the necessary tables (if they don't already exist).
- Next, use the `host_info.sh` script to store the new host's information in the database.
- Then, run the `host_usage.sh` script to log the memory usage data.
- To automate the previous step, modify the crontab by adding the file path to the `host_usage.sh` script with the `* * * * *` marker, which schedules the script to run every minute. This schedule can be adjusted according to the desired automation frequency.

# Architecture

Diagram to be added

# Scripts
- `psql_docker.sh` - can be used to control the docker container, i.e. create, start or stop it
- `ddl.sql` - used to initialize the database and tables
- `host_info.sh` - used to automatically gather host information and then insert it into the database.
- `host_usage.sh` - used to automatically gather the host memory info and store it in the database.

# Database Modelling

The tables used are as follows:

- `host_info`
    - `id` - This is the primary key. Increments each time a new host is added.
    - `hostname` - Name of the host system
    - `cpu_number` - CPU number of the system
    - `cpu_architecture` - Processor architecture
    - `cpu_model` - Type of processor
    - `cpu_mhz` - Processor speed
    - `l2_cache`- L2 cache memory in the CPU
    - `timestamp`- Time of addition to the table
    - `total_mem` - Total memory of the system


- `host_usage`
    - `timestamp`- Time of addition to the table
    - `host_id` - This is the foreign key. Connects this table to host_info
    - `memory_free` - The amount of free memory available
    - `cpu_idle` - Idle RAM usage
    - `cpu_kernel` - Kernel memory
    - `disk_io` - Disk memory used for io operations
    - `disk_available` - Disk memory available

# Test
Manual testing was performed to validate the bash scripts and their DDL functionality.

### psql_docker.sh
After each execution, we verified that the script produced the expected outcome. For example, after running the script, we manually checked the command prompt to confirm that the Docker instance was running.

### host_info.sh and host_usage.sh
For both scripts, we executed them and then manually compared the output from `lscpu` and `vmstat` to ensure the information matched the data stored in the database tables.

# Deployment
Deployed using GitHub for version control, docker so that app can run on multiple machines and crontab used for automation. Docker is utilized to run PostgreSQL in an isolated environment, while `crontab` is used to schedule and execute the `host_usage.sh` script every minute on the host machine.

# Improvements

- Implement functionality within the scripts to isolate high-memory processes, facilitating targeted optimization efforts.
- Enhance user capabilities by providing options to customize filtering criteria based on specific memory usage thresholds.
- Expand the scripts to include sorting features that categorize processes by memory consumption, making it easier for users to prioritize optimization tasks.


