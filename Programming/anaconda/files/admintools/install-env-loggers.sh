#!/bin/bash
# Script to install logging into the activation hook directories
# of environments
#
# 2020 - Derek Feichtinger

function envlist() {
    conda env list --json | jq -r '.envs[]' | grep -E -v 'conda$'
}

if [[ -z "$CONDA_PREFIX" ]]; then
    echo "Error: No conda distribution seems active (CONDA_PREFIX)" >&2
    exit 1
fi

for env in $(envlist); do
    if [[ -e "$env/etc" ]]; then
	echo "Installing into $env"
	mkdir -p $env/etc/conda/activate.d
	cat <<'EOF' > $env/etc/conda/activate.d/log-envname.sh
#!/bin/bash
logger "activated conda module: ${CONDA_PREFIX}"  
EOF
    else
	echo "WARNING: SKIPPING ENV: $env has no /etc" >&2
    fi
done

