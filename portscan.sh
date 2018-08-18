#!/bin/bash
echo "Enter starting IP address :"
read FirstIP
    
echo "Enter last IP address :"
read LastIP

echo "Enter port number to scan :"
read Port
    
nmap -sT $FirstIP-$LastIP -p $Port -oG scanresults
cat scanresults |grep open >scanresults1
cat scanresults1 |cut -f2 -d":" |cut -f1 -d"(" > scanresults-$FirstIP-$LastIP-Port-$Port
cat scanresults-$FirstIP-$LastIP-Port-$Port