#!/usr/bin/env python
# installs a jupyter kernel wrapper solution into the environment's
# $ENVPATH/share/jupyter/kernels/python3/kernel.json kernel definition

# typical envpath at PSI
#     "/opt/psi/Programming/anaconda/2019.07/conda/envs/datascience_py37"

import re
import os
import sys
import shutil
from datetime import datetime
import argparse
parser = argparse.ArgumentParser()

# DEFAULTS
verbose_flag = False

parser.add_argument("envpath", help="conda env path")
parser.add_argument("-v", "--verbose", help="verbose mode",action="store_true")
args = parser.parse_args()

if args.verbose:
    verbose_flag = True

envpath = args.envpath
envname = os.path.basename(envpath)
condaroot = re.sub(r'(.*)/conda/envs/.*', r'\1', envpath)
kwrapper = os.path.join(condaroot, 'admintools/kernelwrapper.sh')
kfile = os.path.join(envpath,"share/jupyter/kernels/python3/kernel.json")

date_time = datetime.now().strftime("%Y%m%d-%H%M%S")

if verbose_flag:
    print("env: %s" % envname)
    print(kwrapper)

if not os.path.isfile(kwrapper):
    sys.stderr.write("Error: no wrapper found at %s\n" % (kwrapper))
    sys.exit(1)

searchstr = r'"argv": \[\n( *"/.*python", *)'
subststr = r'"argv": [\n' + '  "' + kwrapper + '",\n' + '  "' + envname + r'",\n\1'

try:
    with open(kfile,"r") as fp:
        filestr = "".join(fp.readlines())
except IOError:
    sys.stderr.write("Error: Env has no kernel file: %s\n" % kfile)
    sys.exit(0)

if re.search(kwrapper, filestr):
        if verbose_flag:
            print("env %s already contains kernelwrapper" % envpath)
            sys.exit(0)
            
if re.search(searchstr, filestr):
    filestr = re.sub(searchstr,
                     subststr,
                     filestr)
    print(filestr)

    bupfile = kfile + "-" + date_time + ".bup"
    if verbose_flag:
        print("copying original file to %s" % bupfile)
    shutil.copyfile(kfile, bupfile)
    if verbose_flag:
        print("writing new file %s" % kfile)
        print(filestr)
    with open(kfile,"w") as fp:
        fp.write(filestr)
else:
    sys.stderr.write("ERROR: Could not do substitution in %s" % kfile)
    sys.stderr.write(filestr)
