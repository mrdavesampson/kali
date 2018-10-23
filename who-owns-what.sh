#!/bin/bash
#Create a listing of every user which owns a file in a given directory as well as how many files and directories they own


#if len(sys.argv) == 1:
#    DIR = raw_input('Enter Directory Path: ')
#    print ('')
#elif len(sys.argv) == 2:
#    DIR = str(sys.argv[1])
#    print 'ip address = %s' % DIR
#    print ('')
#else:
#    print 'Too many arguments provided'
#    DIR = raw_input('Enter Directory Path: ')
#    print ('')

if [[ $# -ne 1 ]] ; then
   echo "Usage: who-owns-what.sh {path/to/directory/to/enumerate}" >&2
   exit 1
fi


ls -l $1 | tail -n +2 | sed 's/\s\s*/ /g' | cut -d ' ' -f 3 | sort | uniq
