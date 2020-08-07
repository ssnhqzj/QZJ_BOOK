#!/bin/sh

logs=$(find /var/lib/docker/containers/ -name *-json.log) 
for var  in $logs
do
    echo"clean logs : ${var}"
    cat /dev/null > ${var}
done