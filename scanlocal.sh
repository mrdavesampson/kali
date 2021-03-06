#!/bin/bash
# Script to run nmap scan of local subnet
# by mrdavesampson 2018-08-25
#
# TO DO:
#   Parsing of Ping Scan
#   Check other Report formats/options
#   IPCALC CIDR calculations

clear

echo " ___   ___    __    _  _  __    _____  ___    __    __   ";
echo "/ __) / __)  /__\  ( \( )(  )  (  _  )/ __)  /__\  (  )  ";
echo "\__ \( (__  /(__)\  )  (  )(__  )(_)(( (__  /(__)\  )(__ ";
echo "(___/ \___)(__)(__)(_)\_)(____)(_____)\___)(__)(__)(____)";

# set variable for working directory where results will be saved by default
SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"

while :
do
echo
read -r -p "Save scan reults in current directory: "$SCRIPT_DIR"? [Y/n]  " response
response=${response,,}
if [[ $response =~ ^(yes|y)$ ]]
then
   DIR=${SCRIPT_DIR}
   echo
   echo "Scan results will be saved in "$DIR"" && break
else
   echo
   echo "Enter path to directory where results should be saved"
   echo
   read RDIR
   #convert relative path to absolute path
   DIR=$(readlink -f ${RDIR})
   if [ -d "${DIR}" ]
   then
        echo
        echo "Scan results will be saved in "$DIR"" && break
   else
        echo
        read -r -p ""$DIR" does not exist; would you like to create it? [y/N]  " response
        response=${response,,}
        if [[ $response =~ ^(yes|y)$ ]]
        then
            mkdir -p ${DIR}
            if [ -d "${DIR}" ]
            then
                echo
                echo ""$DIR" created successfully" && break
            else
                echo
                echo "Unable to create $DIR directory; Please try again"
            fi
         else
            echo
            echo "No directory chosen ... please try again"
         fi
     fi
fi
done

# check for active network interfaces; if more than 1 prompt user to choose
i=0
echo
echo
echo "Active Network Interfaces: "
echo
# for DEV in `ip addr | awk '/state UP/ {print $2}' | sed 's/.$//'`; do
for DEV in $(ifconfig | grep -E "eth[(0-9)]:|wifi[(0-9)]:|wlan[(0-9)]:" | cut -f1 -d ":"); do
((i++))
ip -o -c addr show | grep -w $DEV | grep -w inet | awk '{printf "%-10s %s\n", $2, $4}'
done

if [ $i -ne 1 ]
then
    echo
    echo "Please select the network interface corresponding to the local subnet you want to scan (e.g. "wlan0" or "eth0"):"
    echo
    ip -o -c addr show | grep -v 127.0.0.1 | grep -v 169.254. | grep -w inet | awk '{printf "%-10s %s\n", $2, $4}'
    echo
    read DEV
    echo "You have chosen interface "$DEV""
fi

# set variables for local subnet based on device chosen
IPADDR="$(ifconfig $DEV | awk '$1 == "inet" {print $2}')"
MASK="$(ifconfig $DEV | awk '$1 == "inet" {print $4}')"
echo
echo "Local IP Address:   "${IPADDR}""
echo "Local Subnet mask:  "${MASK}""

if [[ $MASK = "255.255.255.0" ]]
then
    NETWORK="$(ip -o addr show dev "$DEV" | awk '$3 == "inet" {print $4}' | cut -f1-3 -d ".")"
    SUBNET="${NETWORK}.0/24"
    echo "Local Subnet:       "${SUBNET}""
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
        read -r -p "Scan "$SUBNET" subnet for port(s) "$PORT"; Is this correct? [y/N]  " response
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
        read -r -p "Perform Full Scan of "$SUBNET"; Is this correct? [y/N]  " response
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
        read -r -p "Perform Ping Scan of "$SUBNET"; Is this correct? [y/N]  " response
        response=${response,,}
        if [[ $response =~ ^(yes|y)$ ]]
        then
            OPTS="-sn"
           # REP=""
           # FN=""
           # jumpto SCAN
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
        exit 0
        ;;

    *) echo "Invalid Scan Option ..."
    echo
    jumpto $START
    ;;
esac
echo
# prompt for stealth mode unless ping scan
if [[ $OPTS != "-sn" ]]
then
    read -r -p "Use Stealth Mode? [y/N]" stealth
    stealth=${stealth,,}
    if [[ $stealth =~ ^(yes|y)$ ]]
    then
        OPTS="${OPTS} -sS"
    fi
fi
echo
echo "Select report option:"
while true
do
echo
echo "   N: -oN Normal NMAP Output; no parsing will be done"
echo "   O: -oG List IPs with Open Ports or Online Hosts (valid only for Port & Ping scans)"
echo "   X: -Ox XML Output"
echo "   A: -oA All formats: normal, XML, and grepable"
echo "   I: Interactive only - results will be output to screen but not saved"
echo "   Q: Quit without scanning"
echo
read REPOPT

case $REPOPT in
    [nN] )
        REP="-oN"
        FN=""$DIR"/scanresults-$NETWORK-$OPTS"
        break
        ;;
    [oO] )        
        case $OPTION in
        ([pP])
            REP="-oG"
            FN=""$DIR"/scanresults-$NETWORK-port-$PORT"
            break
            ;;
        ([sS])
            REP="-oG"
            FN=""$DIR"/scanresults-$NETWORK-online_hosts"
            break
            ;;
        *)  
            echo
            echo "Sorry, -oG is not valid report option for a "${OPTS}" scan "
            ;;
        esac    
        ;;
    [xX] )
        echo
        REP="-oX"
        FN=""$DIR"/scanresults-$NETWORK-$OPTS.xml"
        break
        ;;
    [aA] )
        echo
        REP="-oA"
        FN=""$DIR"/scanresults-$NETWORK-$OPTS"
        break
        ;;
    [iI] )
        echo
        REP=""
        FN=""
        break
        ;;
    [qQ] )
        exit 0
        ;;
      *)
        echo
        echo "Please Enter a Valid Report Option ... "
        ;;
esac
done
echo "Summary:"
echo
echo "DEVICE:    "$DEV""
echo "NETWORK:   "$NETWORK""
echo "SUBNET:    "$SUBNET""
echo "OPTIONS:   "$OPTS"" 
#echo "OPTION=  "$OPTION""
#echo "REPOPT= "$REPOPT""
echo "OUTPUT:    "$REP""
#echo "DIRECTORY: "$DIR""
echo "FILENAME:  "$FN""


# final confirmation of options and actual nmap scan
#SCAN:
echo
read -p "Press enter to continue"
#read -r -p "Perform Scan of "$SUBNET" with options: "${OPTS}" "${REP}"? [y/N]  " response
#response=${response,,}
#if [[ $response =~ ^(yes|y)$ ]]
#then
    echo
    echo
    echo "Performing NMAP Scan of "$SUBNET" with options: "${OPTS}" "${REP}" now ..."
    echo
    nmap ${OPTS} ${SUBNET} ${REP} ${FN}
    echo
    if [[ $REP = "-oG" ]]
    then
        # if [[ $OPTION =~ ^(pP)$ ]]
        if [[ ${OPTION,,} = p ]]
        # Port Scan with Report Option O: Parse OPEN Ports
        then
            cat "$FN" | grep open > portsopen
            cat portsopen |cut -f2 -d ":" |cut -f1 -d"(" > $FN
            #clean-up temp results files and then display final results
            echo
            echo "Cleaning up temp files ... "
            #rm -f scanresults
            rm -f portsopen
            echo
            echo "Showing list of vulnerable ip addresses now ..."
            echo
            cat $FN
            echo
            echo "Results have been saved to "$FN""
            echo
            echo
        else
        # Ping Scan with Report Option O: Parse Online Hosts
            cat "$FN" | grep Up > hosts 
            cat hosts | cut -f2 -d ":" | cut -f1 -d"(" > $FN
            #clean-up temp results files and display final results
            echo
            echo "Cleaning up temp files ... "
            #rm -f scanresults
            rm -f hosts
            echo
            echo "Showing list of online hosts now ..."
            echo
            cat $FN
            echo
            echo "Results have been saved to "$FN""
            echo
            echo
        fi
    elif [ -z "$REP" ]
    then
        echo
        echo "Interactive Scan Complete, Goodbye."
        echo
        echo
        exit 0
    else
        echo
        echo "Results have been saved to "$FN""
        echo
        echo
    fi
#else
#    jumpto $START
#fi
exit 0
