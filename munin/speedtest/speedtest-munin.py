#!/usr/bin/python3

import speedtest

servers = []
# If you want to test against a specific server
# servers = [1234]

s = speedtest.Speedtest()
s.get_servers(servers)
s.get_best_server()
s.download()
s.upload()

results_dict = s.results.dict()
print(round(results_dict['download']))
print(round(results_dict['upload']))

