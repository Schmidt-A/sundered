import os
import subprocess
import sys

SCRIPT_DIR = 'scripts/'
TOOLS_DIR  = 'tools/'

BIOWARE_SCRIPTS = SCRIPT_DIR + 'bioware_scripts/'
COMPILER        = TOOLS_DIR + 'nwnnsscomp'


def help():
    print 'Usage: python compiler.py [-h] all OR script_file\n'
    print '\tscript file:\tnss script file to compile'
    print '\tall:\t\tcompile all script files'
    print '\t-h:\t\tshow help'
    sys.exit()


def compile_nss(nss_file):
    if not nss_file.startswith(SCRIPT_DIR):
        nss_file = SCRIPT_DIR + nss_file

    # ./tools/nwnnsscomp -i scripts/bioware_scripts/ -c scripts/mod_playerenter.nss
    print '\nCompiling nss file ' + nss_file + "..."
    cmd = COMPILER + ' -i ' + BIOWARE_SCRIPTS + ' -c ' + nss_file
    print subprocess.Popen(cmd, shell=True,
            stdout=subprocess.PIPE).stdout.read()
    print '... done'


def clean():
    print '\nRemoving generated ncs files...'
    cmd = 'rm ' + SCRIPT_DIR + '*ncs'
    print subprocess.Popen(cmd, shell=True,
            stdout=subprocess.PIPE).stdout.read()
    print '...done'


def main(args):
    if len(args) == 0 or args[0] == '-h':
        help()
    elif args[0] == 'all':
        for fname in os.listdir(SCRIPT_DIR):
            if fname.endswith('.nss'):
                compile_nss(fname)
        clean()
    else:
        compile_nss(args[0])
        clean();


if __name__ == '__main__':
    main(sys.argv[1:])
    sys.exit()
