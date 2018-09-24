#!/usr/bin/env python
# shohost.py
# Search SHODAN for specific host IP and print details
# Author: j.r.bob.dobbs

import shodan
import sys

SHODAN_API_KEY = "iCGUBqXdugiTqPOWnbIa3VNvskxuAcMJ"
api = shodan.Shodan(SHODAN_API_KEY)

# Input validation
if len(sys.argv) == 1:
        print 'Usage: %s <ip address of host to query>' % sys.argv[0]
        sys.exit(1)

try:
	# Lookup the host
	query = ' '.join(sys.argv[1:])
	host = api.host(query)

	# Print general info
	print("""
			IP: {}
			Organization: {}
			Operating System: {}
	""".format(host['ip_str'], host.get('org', 'n/a'), host.get('os', 'n/a')))

	# Print all banners
	for item in host['data']:
			print("""
					Port: {}
					Banner: {}

			""".format(item['port'], item['data']))

except Exception as e:
        print 'Error: %s' % e
        sys.exit(1)
