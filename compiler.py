import os
import subprocess
import sys

from StringIO import StringIO

SCRIPT_DIR = 'scripts/'
TOOLS_DIR  = 'tools/'

BIOWARE_SCRIPTS = SCRIPT_DIR + 'bioware_scripts/'
COMPILER        = TOOLS_DIR + 'nwnnsscomp'

error_list = []

def help():
    print 'Usage: python compiler.py [-h] all OR script_file\n'
    print '\tscript file:\tnss script file to compile'
    print '\tall:\t\tcompile all script files'
    print '\t-h:\t\tshow help'
    sys.exit()


def run_cmd(cmd):
    p = subprocess.Popen(cmd, shell=True, stdin=subprocess.PIPE,
            stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = p.communicate()
    ret = p.returncode

    ret_msg = ''
    s = StringIO(out)
    for line in s:
        if 'Compiling' in line:
            ret_msg += line
        if 'Error' in line:
            ret_msg += line

    return ret, ret_msg


def compile_nss(nss_file):

    if not nss_file.startswith(SCRIPT_DIR):
        nss_file = SCRIPT_DIR + nss_file

    # ./tools/nwnnsscomp -i scripts/bioware_scripts/ -c scripts/mod_playerenter.nss
    cmd = COMPILER + ' -i ' + BIOWARE_SCRIPTS + ' -c ' + nss_file

    ret, out = run_cmd(cmd)
    if ret > 0:
        s = StringIO(out)
        for line in s:
            if 'Error' in line and 'Errors' not in line:
                error_list.append(line)
    print out


def clean():
    print '\nRemoving generated ncs files...'
    cmd = 'rm ' + SCRIPT_DIR + '*ncs'
    print subprocess.Popen(cmd, shell=True,
            stdout=subprocess.PIPE).stdout.read()
    print '...done\n------------------------------------------'


def error_summary():
    print 'COMPILE ERRORS:'
    for err in error_list:
        print err


def main(args):
    if len(args) == 0 or args[0] == '-h':
        help()
    elif args[0] == 'all':
        for fname in os.listdir(SCRIPT_DIR):
            if fname.endswith('.nss'):
                compile_nss(fname)
        clean()
        error_summary()
    else:
        compile_nss(args[0])
        clean()
        error_summary()


if __name__ == '__main__':
    main(sys.argv[1:])
    sys.exit()
