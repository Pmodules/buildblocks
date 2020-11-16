#!/bin/bash
# kernelwrapper.sh
# This wrapper is needed to correctly have jupyter activate conda evnironments
# including the running of the $ENV/etc/conda/activate.d hooks
# q.v. https://github.com/Anaconda-Platform/nb_conda_kernels/issues/145
#
# This script must be called from the config located in an environment
#   $ENV/share/jupyter/kernels/python3/kernel.jsonshare/jupyter/kernels/python3/kernel.json 

# 2019 - Derek Feichtinger
dbgecho() {
    DBGLOG=/tmp/kernelwrapper-${USER}.log
    if [[ $DEBUG_JUPYTER_WRAPPER == 1 ]]; then
	echo "$1" >> $DBGLOG
    fi
}

DATE=$(date +%Y-%m-%dT%H:%M)
dbgecho "$DATE: $@" 

# ensure that module commands are available
dbgecho "sourcing profile.bash"
source /opt/psi/config/profile.bash

dbgecho "sourcing conda.sh"
source /opt/psi/Programming/anaconda/2019.07/conda/etc/profile.d/conda.sh &>> $DBGLOG

dbgecho "Running activate"
conda activate $1

# undefine module command since it causes error in the notebook when using
# shell escapes
unset -f module
shift
exec "$@"

