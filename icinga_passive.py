#!/usr/bin/env python3

import requests, json, sys, time, getopt, shlex, subprocess, configparser, os

def usage():
    print('Usage: passive.py -H <host> -S <service> -C <command> -N <icinga host>')


try:
    opts, args = getopt.getopt(sys.argv[1:], 'H:S:C:N:c:')
except getopt.GetoptError as err:
    print(str(err))
    usage()
    sys.exit(2)

if len(args) > 0:
    usage()
    sys.exit(2)

for o, a in opts:
    if o == '-H':
        host = a
    elif o == '-S':
        service = a
    elif o == '-C':
        command = a
    elif o == '-N':
        icinga_host = a

try:
    host
    service
    command
    icinga_host
except NameError:
    usage()
    sys.exit(2)

path = os.path.dirname(os.path.abspath(__file__)) + '/'
configfile = path + 'icinga_passive.properties'
settings = configparser.ConfigParser()
settings.read(configfile)

if icinga_host not in settings or 'username' not in settings[icinga_host] or 'password' not in settings[icinga_host]:
    print('Configuration file %s not found or invalid' % configfile)
    sys.exit(3)

request_url = "https://%s:5665/v1/actions/process-check-result" % icinga_host

command_args = shlex.split(command)

execution_start = round(time.time())
out = subprocess.Popen(command_args, stderr = subprocess.STDOUT, stdout = subprocess.PIPE)
output = out.communicate()[0].strip().decode('UTF-8')
print(output)
execution_end = round(time.time())

parts = output.split('|')
plugin_output = parts[0]
if len(parts) > 1:
    performance_data = parts[1]
else:
    performance_data = ''
exit_status = out.returncode

filter = ('host.name=="%s" && service.name=="%s"' % (host, service))

headers = {
    'Accept': 'application/json'
}
data = {
    'type': 'Service',
    'exit_status': exit_status,
    'plugin_output': plugin_output,
    'performance_data': performance_data,
    'check_command': command,
    'check_source': host,
    'execution_start': execution_start,
    'execution_end': execution_end,
    'filter': filter
}

username = settings[icinga_host]['username']
password = settings[icinga_host]['password']

submitted = False
for i in range(0,5):
    try:
        r = requests.post(request_url,
            headers=headers,
            auth=(username, password),
            data=json.dumps(data),
            timeout=10)
        submitted = True
        break
    except requests.exceptions.Timeout:
        print('Timeout while submitting passive check result (iteration %s)' % (i, ))
    except requests.exceptions.ConnectionError:
        print('Error while submitting passive check result (iteration %s)' % (i, ))

if not submitted:
    print('Unable to submit passive check result, giving up')
    sys.exit(3)

if (r.status_code == 200):
    json = r.json()
    result = json['results'][0]
    if result['code'] == 200:
        print('Status for service "%s" on host "%s" sent successfully' % (service, host))
    else:
        print('Application error %s when sending status for service "%s" on host "%s": %s' % (int(result['code']), service, host, result['status']))
        sys.exit(2)
else:
    print('HTTP error %s while sending status for service "%s" on host "%s"' % (r.status_code, service, host))
    sys.exit(1)

