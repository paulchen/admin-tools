#!/usr/bin/env python3

import os, sys, subprocess

path = os.path.dirname(os.path.abspath(__file__)) + '/'
nsca_wrapper = path + 'nsca_wrapper'
icinga_passive = path + 'icinga_passive.py'

subprocess.call([nsca_wrapper] + sys.argv[1:])
subprocess.call([icinga_passive] + sys.argv[1:])

