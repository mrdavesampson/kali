#!/bin/bash

if [ $# -eq 0 ]; then
   	echo "Usage: scanresults.sh {filename containing list of IPs to scan}" >&2
    exit 1
fi

cat $1 | while read line
	do
	nmap -sS $line
done
	
	
