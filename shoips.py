#!/usr/bin/env python
# shoips.py
# Search SHODAN by keyword(s) and return list of matching ip addresses
# Author: j.r.bob.dobbs

import shodan
import sys

SHODAN_API_KEY = "iCGUBqXdugiTqPOWnbIa3VNvskxuAcMJ"
api = shodan.Shodan(SHODAN_API_KEY)

# Input validation
if len(sys.argv) == 1:
        print 'Usage: %s <search query: webcamxp, apache, etc>' % sys.argv[0]
        sys.exit(1)

try:
	# Search Shodan
	query = ' '.join(sys.argv[1:])
	results = api.search(query)
	#results = api.search('webcamxp')

	# Show the results
	for result in results['matches']:
		print '%s' % result['ip_str']
except Exception as e:
        print 'Error: %s' % e
        sys.exit(1)
