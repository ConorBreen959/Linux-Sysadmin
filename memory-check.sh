#!/bin/bash

message="Status report:\n"

status_code=0

root_partition=""
root_size=1000000

home_partition=""
home_size=5000000

root=$(sudo df | grep $root_partition | awk '{print $4}')

home=$(sudo df | grep $home_partition | awk '{print $4}')

if [[ "$root" -le $root_size ]]; then
        message="${message}\nRoot space is below limit, server is close to falling over!"
        status_code=1
fi

if [[ "$home" -le $home_size ]]; then
        message="${message}\nHome space is below limit, gitlab may stop working soon!"
        status_code=2
fi



if [[ $status_code -ne 0 ]]; then
        echo -e "$message" | mail -s "RE: Gitlab Server Memory Alert" conor.breen@plusvital.com
fi
