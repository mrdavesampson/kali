#!/usr/bin/python
import pygeoip
import sys

# TO DO:
# check to see if argument was passed
# if not, prompt for IP
# check to make sure IP is valid
# if not valid print usage & prompt for IP

if len(sys.argv) == 1:
    ip = raw_input('IP to GeoLocate: ')
    print ('') 
elif len(sys.argv) == 2:
    ip = str(sys.argv[1])
    print 'ip address = %s' % ip
    print ('')
else:
    print 'Too many arguments provided'
    ip = raw_input('IP to GeoLocate: ')
    print ('')
    
    
gip = pygeoip.GeoIP('/root/pygeoip-0.3.2/GeoLiteCity.dat')
rec = gip.record_by_addr(ip)
for key,val in rec.items():
    print "%s: %s" % (key,val)

print('')    
