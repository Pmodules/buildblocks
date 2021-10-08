#!/bin/bash
#SBATCH -p day
#SBATCH -t 1-00:00:00
#SBATCH -J alphafold
#SBATCH -n 1
#SBATCH -c 10

# Alphafold submission script for the ra cluster
# Usage: sbatch [slurm_opts] $ALPHAFOLD_DIR/bin/submit_merlin.sh fasta_file [max_template_date]
#
# Output will be in the same directory as the fasta_file.
# Slurm logs will be in the current directory.
#
# 2021-08-09 Spencer Bliven, D.Ozerov
#

export ALPHAFOLD_DATA=/das/work/common/opt/alphafold/data

# Need at least rc6 to see alphafold
PMODULES_VERSION=1.0.0rc10;
source /opt/psi/config/profile.bash;

module --version

module purge
module use MX unstable Programming
module load alphafold/ALPHAFOLD_VERSION
module list

exec "${ALPHAFOLD_DIR:?Error loading module}/bin/submit.sh" "$@"
