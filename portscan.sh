#!/bin/bash
# Script to run nmap scan of selected Class C address block on selected port(s)
# and clean-up results to return list of ip addresses with open port(s)
# based on Null Byte script by OTW and modifications by appledash48:
# https://null-byte.wonderhowto.com/how-to/hack-like-pro-scripting-for-aspiring-hacker-part-1-bash-basics-0149422/
# this version by mrdavesampson 2018-08-18

# set variable for working directory where results will be saved
SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"

# boilerplate function for GOTO functionality (jumpto)
function jumpto
{
    label=$1
    cmd=$(sed -n "/$label:/{:a;n;p;ba};" $0 | grep -v ':$')
    eval "$cmd"
    exit
}
start=${1:-"start"}
jumpto $start

start:
#script starts here
echo
echo "Enter IP address block to scan (/24)"
echo "Example: google.com is 74.125.225.0"
echo
read IP
echo
echo "Enter port to be scanned"
echo "Example: 5505"
echo "Example2: To scan multiple ports, format it like this: 5505-6000"
echo
read PORT
echo
read -r -p "Scanning "$IP" subnet for port "$PORT"; Is this correct? [y/N]" response
response=${response,,}
if [[ $response =~ ^(yes|y)$ ]]
then
    echo
    echo "Scanning "$IP" on port "$PORT" now ..."
    echo
    nmap -sT $IP/24 -p $PORT -oG scanresults
    cat scanresults |grep open > portsopen
    cat portsopen |cut -f2 -d ":" |cut -f1 -d"(" > scanresults-$IP-port-$PORT
    #clean-up temp results files and then display final results
    echo
    echo "Cleaning up temp files ...."
    rm -f scanresults
    rm -f portsopen
    echo
    echo "Showing list of vulnerable ip addresses now ..."
    echo
    cat scanresults-$IP-port-$PORT
    echo
    echo "Results have been saved to "$SCRIPT_DIR"/scanresults-"$IP"-port-"$PORT""
    echo
    echo
else
     jumpto $start
fi #Cx2H

