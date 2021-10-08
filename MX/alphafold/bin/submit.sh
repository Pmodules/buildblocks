#!/bin/bash

# Generic alphafold submission script.
# Set the ALPHAFOLD_DATA variable before running.
# Usage: sbatch [slurm_opts] $ALPHAFOLD_DIR/bin/submit.sh fasta_file [max_template_date]
#
# Output will be in the same directory as the fasta_file.
# Slurm logs will be in the current directory.
#
# 2021-08-09 Spencer Bliven, D.Ozerov
#

# Bash strict mode
set -euo pipefail
IFS=$'\n\t'

usage () {
    echo "Usage: sbatch [slurm_opts] \$ALPHAFOLD_DIR/bin/submit_merlin.sh fasta_file [max_template_date]"
}

# Parse parameters
if [ "$#" -lt 1 ]
then
    echo "No fasta_file name" >&2
    usage >&2
    exit
fi

FASTA_FILE=`readlink -f $1`
if [ ! -e ${FASTA_FILE} ] || [ "$FASTA_FILE" == "" ]
then
    echo "${FASTA_FILE} is not reachable (input argument was $1)"
    exit
fi

DIR_QUERY=`dirname ${FASTA_FILE}`
LOG="${DIR_QUERY}/alphafold.out"

if [ "$#" -ge 2 ]
then
    MAX_TEMPLATE_DATE=$2
else
    MAX_TEMPLATE_DATE=$(date '+%Y-%m-%d')
fi

date     > "$LOG"
hostname >> "$LOG"

set +u # Allow unset variables in activate commands
module purge
module use MX unstable
module load alphafold/ALPHAFOLD_VERSION 2>> "$LOG"
conda activate "${ALPHAFOLD_ENV:?"Error: ALPHAFOLD_ENV not set. Try 'module use MX unstable; module load alphafold'"}"
set -u

# Check the module loaded correctly
if ! [ -d "${ALPHAFOLD_HOME}" ]; then
    echo "Error: $ALPHAFOLD_HOME not available" >&2
    exit 1
fi

# Data dir
if ! [ -d "${ALPHAFOLD_DATA:?Set ALPHAFOLD_DATA before running}" ]; then
    echo "Error: ALPHAFOLD_DATA directory not available ($ALPHAFOLD_DATA)" >&2
    exit 1
fi

echo "GPUs: ${CUDA_VISIBLE_DEVICES:-None}" >> "$LOG"
echo "Detecting GPUs with Tensorflow:" >> "$LOG"
python -c 'import tensorflow as tf; tf.compat.v1.Session(config=tf.compat.v1.ConfigProto(log_device_placement=True))' 2>&1 |
    sed -rn 's/^.* (Created TensorFlow device.*)$/\1/p' >> "$LOG"
echo >> "$LOG"

echo "Running alphafold from $PWD for fasta sequence : " >> "$LOG"
cat ${FASTA_FILE} >> "$LOG"
echo "and max_template_date : ${MAX_TEMPLATE_DATE} " >> "$LOG"
echo >> "$LOG"


cd "${ALPHAFOLD_HOME}"
CMD=("./run_alphafold.sh" -p full_dbs -d "${ALPHAFOLD_DATA}" -o "${DIR_QUERY}" -m model_1,model_2,model_3,model_4,model_5 -f "${FASTA_FILE}" -t "${MAX_TEMPLATE_DATE}")
if [ -z "${CUDA_VISIBLE_DEVICES:-}" ]
then
    CMD+=(-g false)
else
    CMD+=(-a "$CUDA_VISIBLE_DEVICES")
fi

echo "Run: ${CMD[@]}" >> "$LOG"
echo >> "$LOG"
( ( time "${CMD[@]}" ) 2>&1 ) >> "$LOG"
