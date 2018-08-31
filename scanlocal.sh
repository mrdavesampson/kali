#!/bin/bash
# Script to run nmap scan of local subnet
# by mrdavesampson 2018-08-25
#
# TO DO: 
#   Present File Output Options: List of IPs with Open Ports vs ??
#   Filename to Reflect Scan Type (Port only for Port Scans)
#   IPCALC CIDR calculations

clear

echo " ___   ___    __    _  _  __    _____  ___    __    __   ";
echo "/ __) / __)  /__\  ( \( )(  )  (  _  )/ __)  /__\  (  )  ";
echo "\__ \( (__  /(__)\  )  (  )(__  )(_)(( (__  /(__)\  )(__ ";
echo "(___/ \___)(__)(__)(_)\_)(____)(_____)\___)(__)(__)(____)";


# set variable for working directory where results will be saved
SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"

# have user select interface to use and store that in a variable
echo
echo "Please select the network interface corresponding to the local subnet you want to scan (e.g. "wlan0" or "eth0"):"
echo
ip -o -c addr show | grep -v 127.0.0.1 | grep -w inet | awk '{printf "%-10s %s\n", $2, $4}'
echo
read DEV

# set variables for local subnet based on device chosen
IPADDR="$(ifconfig $DEV | awk '$1 == "inet" {print $2}')"
MASK="$(ifconfig $DEV | awk '$1 == "inet" {print $4}')" 
echo
echo "You have chosen interface "$DEV""   
echo
echo "Local IP Address is "${IPADDR}""
echo 
echo "Local Subnet mask is "${MASK}""
echo

if [[ $MASK = "255.255.255.0" ]]
then 
    NETWORK="$(ip -o addr show dev "$DEV" | awk '$3 == "inet" {print $4}' | cut -f1-3 -d ".")"
    SUBNET="${NETWORK}.0/24"
    echo "Local Subnet in CIDR Notation is "${SUBNET}""
    echo
else 
    echo "This is not a /24 Subnet"
    echo 
    echo "Checking for ipcalc ..."
    echo
    # check for ipcalc program
    if ! [ -x "$(command -v ipcalc)" ]; then
        # using first 3 octets to form /24     
        NETWORK="$(ip -o addr show dev "$DEV" | awk '$3 == "inet" {print $4}' | cut -f1-3 -d ".")"
        SUBNET="${NETWORK}.0/24"
        echo "ipcalc is not installed; defaulting to /24 subnet: "${SUBNET}""
        echo
    else
        echo "ipcalc installed. will calculate CIDR" 
        echo
    fi    
fi


# boilerplate function for GOTO functionality (jumpto)
function jumpto
{
    label=$1
    cmd=$(sed -n "/$label:/{:a;n;p;ba};" $0 | grep -v ':$')
    eval "$cmd"
    exit
}
START=${1:-"START"}
jumpto $START

START:
#user options & confirmation loop starts here
echo
echo "Select scan options:"
echo "   A: -A [Enable OS detection, version detection, script scanning, and traceroute]"
echo "   P: -p [Scan specific port(s) or port range]"
echo "   S: -sn [Ping Scan - disable port scan]"
echo "   M: Manually Specify Scan Options"
echo "   Q: Quit without scanning"
echo
read OPTION

case $OPTION in
    [pP] ) 
        echo
        echo "Enter port to be scanned"
        echo "Example: 5505"
        echo "Example2: To scan multiple ports, format it like this: 1-15000 or 80,443,8080"
        echo
        read PORT
        echo
        read -r -p "Scan "$SUBNET" subnet for port(s) "$PORT"; Is this correct? [y/N]" response
        response=${response,,}
        if [[ $response =~ ^(yes|y)$ ]] 
        then 
            OPTS="-p "$PORT""
        else
            jumpto $START
        fi    
        ;;

    [aA] )
        echo 
        read -r -p "Perform Full Scan of "$SUBNET"; Is this correct? [y/N]" response
        response=${response,,}
        if [[ $response =~ ^(yes|y)$ ]] 
        then 
            OPTS="-A"
        else
            jumpto $START
        fi    
        ;;

    [sS] )
        echo 
        read -r -p "Perform Ping Scan of "$SUBNET"; Is this correct? [y/N]" response
        response=${response,,}
        if [[ $response =~ ^(yes|y)$ ]] 
        then 
            OPTS="-sn"
            jumpto SCAN
        else
            jumpto $START
        fi    
        ;;


    [mM] ) 
        echo
        echo "Enter scan options using correct syntax (NOTE: Stealth option will be selected later)"
        echo "Example: -p 1-65535 -sV [Full TCP port scan with service version detection]"
        echo "Example2: -v -p 1-65535 -sV -O -T4 [full port scan with verbose output, T4 timing, OS and version detection]"
        echo
        read OPTIONS
        echo
        echo "Scan "$SUBNET" subnet using options: "${OPTIONS}"; Is this correct? [y/N]"
        read response
        response=${response,,}
        if [[ $response =~ ^(yes|y)$ ]] 
        then 
            OPTS="${OPTIONS}"
        else
            OPTS=""
            jumpto $START
        fi    
        ;;

    [qQ] ) 
        echo
        echo
        exit 
        ;;

    *) echo "Invalid Scan Option ..."
    echo
    jumpto $START
    ;;
esac
echo
echo
read -r -p "Use Stealth Mode? [y/N]" stealth
stealth=${stealth,,}
if [[ $stealth =~ ^(yes|y)$ ]]
then
    OPTS="${OPTS} -sS"
fi    

# final confirmation of options and actual nmap scan
SCAN:
echo
echo "Perform Scan of "$SUBNET" with options: "${OPTS}"? [y/N]"
read response
if [[ $response =~ ^(yes|y)$ ]] 
then 
    echo    
    echo
    echo "Performing NMAP Scan of "$SUBNET" with options: "${OPTS}" now ..."
    echo
    nmap ${OPTS} ${SUBNET} -oG scanresults
    cat scanresults |grep open > portsopen
    cat portsopen |cut -f2 -d ":" |cut -f1 -d"(" > scanresults-$NETWORK-port-$PORT
    #clean-up temp results files and then display final results
    echo
    echo "Cleaning up temp files ...."
    rm -f scanresults
    rm -f portsopen
    echo
    echo "Showing list of vulnerable ip addresses now ..."
    echo
    cat scanresults-$NETWORK-port-$PORT
    echo
    echo "Results have been saved to "$SCRIPT_DIR"/scanresults-"$NETWORK"-port-"$PORT""
    echo
    echo
else
    jumpto $START
fi    
