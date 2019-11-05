echo "Running hook for removing PSI modules" >&2
if [[ x$(command -v module) = x ]]; then
    echo "setting up module env" >&2
    # source /opt/psi/config/profile.bash
    module() {
        unset BASH_ENV;
        eval $("${PMODULES_HOME}/bin/modulecmd" bash "$@")
    }
fi
echo "DEBUG: loaded modules prior to removal" >&2
module list >&2
module unload cuda/9.2.148 MotionCor2/1.2.0 IMOD/4.9.5 >&2
echo "DEBUG: loaded modules after removal" >&2
module list >&2
