# simulate `conda init` type hook
# Expects CONDA_EXE and CONDA_PREFIX to be set
__conda_setup="$("${CONDA_EXE:-conda}" 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "${CONDA_PREFIX:?CONDA_PREFIX not set}/etc/profile.d/conda.sh" ]; then
        . "${CONDA_PREFIX}/etc/profile.d/conda.sh"
    else
        export PATH="${CONDA_PREFIX}/bin:$PATH"
    fi
fi
unset __conda_setup

