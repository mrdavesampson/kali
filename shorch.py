#!/usr/bin/env python
# shorch.py
# Search SHODAN and print detailed results
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

	# Show the results
	print 'Results found: %s' % results['total']
	for result in results['matches']:
		print 'IP: %s' % result['ip_str']
		print result['data']
		print ''
except shodan.APIError, e:
	print 'Error: %s' % e