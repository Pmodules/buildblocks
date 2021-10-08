#!/bin/bash
#SBATCH -p gpu
#SBATCH -J alphafold
#SBATCH -M gmerlin6
#SBATCH --gpus=1
#SBATCH -n 1
#SBATCH -c 10

# Alphafold submission script for the merlin cluster
# Usage: sbatch [slurm_opts] $ALPHAFOLD_DIR/bin/submit_merlin.sh fasta_file [max_template_date]
#
# Output will be in the same directory as the fasta_file.
# Slurm logs will be in the current directory.
#
# 2021-08-09 Spencer Bliven, D.Ozerov
#

export ALPHAFOLD_DATA=/data/project/bio/shared/alphafold
module purge
module use MX unstable
module load alphafold/ALPHAFOLD_VERSION

exec "${ALPHAFOLD_DIR:?Error loading module}/bin/submit.sh" "$@"
