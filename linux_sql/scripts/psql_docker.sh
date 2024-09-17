#!/bin/sh

# Capture CLI arguments
cmd=$1
db_username=$2
db_password=$3

# Ensure Docker is running
sudo systemctl status docker > /dev/null 2>&1 || sudo systemctl start docker

# Define the action based on the command argument
case $cmd in
  create)
    # Check if the container already exists
    docker container inspect jrvs-psql > /dev/null 2>&1
    container_status=$?
    if [ $container_status -eq 0 ]; then
        echo 'Container already exists'
        exit 1
    fi

    # Check for correct number of arguments
    if [ $# -ne 3 ]; then
        echo 'Create requires username and password'
        exit 1
    fi

    # Create a new volume for PostgreSQL data, if it does not already exist
    docker volume create pgdata

    # Create and start the PostgreSQL container
    docker run --name jrvs-psql -e POSTGRES_USER=$db_username -e POSTGRES_PASSWORD=$db_password -d -v pgdata:/var/lib/postgresql/data -p 5432:5432 postgres:9.6-alpine
    echo "Container created and started successfully."
    ;;

  start|stop)
    # Check if the container has been created
    docker container inspect jrvs-psql > /dev/null 2>&1
    container_status=$?

    if [ $container_status -ne 0 ]; then
        echo 'Container has not been created'
        exit 1
    fi

    # Start or stop the container
    docker container $cmd jrvs-psql
    echo "Container ${cmd}ed successfully."
    ;;

  *)
    echo 'Illegal command'
    echo 'Commands: start|stop|create'
    exit 1
    ;;
esac

exit 0
