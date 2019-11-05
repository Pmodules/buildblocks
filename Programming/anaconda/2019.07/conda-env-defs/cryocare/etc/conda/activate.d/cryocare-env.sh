#!/bin/bash
echo "Running hook for adding PSI modules" >&2
if [[ x$(command -v module) = x ]]; then
    echo "setting up module env" >&2
    # source /opt/psi/config/profile.bash
    module() {
        unset BASH_ENV;
        eval $("${PMODULES_HOME}/bin/modulecmd" bash "$@")
    }
fi

module use unstable
module use EM
module load cuda/9.2.148 MotionCor2/1.2.0 IMOD/4.9.5
echo "DEBUG: loaded modules after addition:" >&2
module list >&2
