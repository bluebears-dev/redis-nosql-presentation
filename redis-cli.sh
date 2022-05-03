#!/bin/env bash

set -e 
set -o pipefail

RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

function print_error() { 
    echo -e "${RED}${1}${NC}" >&2
}

function print_info() { 
    echo -e "${CYAN}${1}${NC}"
}

function assert_parameter() {
    if [ ! "${1}" ]; then
        print_error "Container name not provided. Please provide where redis-cli should be started."
        exit 1
    fi
}

function find_container() {
    docker ps -q -f status=running -f name=^/${1}$
}

function start_containers() {
    CID=$(find_container $1)
    echo $CID
    if [ ! "${CID}" ]; then
        print_info "Container isn't up. Running docker-compose in detached mode..."
        docker-compose up -d
    fi
    unset CID

    CID=$(find_container $1)
    if [ ! "${CID}" ]; then
        print_error "Provided container name is not defined in docker-compose.yml"
        print_error "Please check if this isn't a typo: '${1}'"
        print_info "Stopping started containers..."
        docker-compose down
        exit 2
    fi
    unset CID
}

assert_parameter $1
start_containers $1

print_info "Starting redis-cli in '${1}'..."
print_info "Type ${NC}exit${CYAN} to exit from the redis-cli"
docker exec -it $1 redis-cli

exit 0