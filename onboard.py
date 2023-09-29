import sys, getopt, os, errno, json, subprocess, tempfile

def usage():
    print ("""Usage: %s
    Performs onboarding
""" % sys.argv[0])
    pass

try:
    opts, args = getopt.getopt(sys.argv[1:], 'hc', ['help', 'config='])

    for k, v in opts:
        if k == '-h' or k == '--help':
            usage()
            sys.exit(0)

except getopt.GetoptError as e:
    print (e)
    print ('')
    usage()
    sys.exit(2)

try:
    # check if directory exists
    if os.path.exists('/mnt/containerTmp'):
        print('Directory /mnt/containerTmp exists')
        destfile = '/mnt/containerTmp/onboarding.json'
    else:
        print('Directory /mnt/containerTmp does not exist')
        destfile = '/tmp/onboarding.json'

    if os.geteuid() != 0:
        print('Re-running as sudo (you may be required to enter sudo''s password)')
        os.execvp('sudo', ['sudo', 'python'] + sys.argv)

    print('Generating %s ...' % destfile)

    # cmd = "sudo mkdir -p '%s'" % (os.path.dirname(destfile))
    # subprocess.check_call(cmd, shell = True)

    with open(destfile, "w") as json:
        json.write('''{
    "success": true,
    "date": 
}''')

    cmd = "logger -p warning succeeded to save json file %s." % (destfile)
    subprocess.check_call(cmd, shell = True)

except Exception as e:
    print(str(e))
    cmd = "logger -p error failed to save json file %s. Exception occured: %s. " % (destfile, str(e))
    subprocess.call(cmd, shell = True)
    sys.exit(1)