#!/bin/bash -e

# The following Relion variables were defined:
# queue         XXXqueueXXX
# mpinodes      XXXmpinodesXXX
# threads       XXXthreadsXXX
# cores         XXXcoresXXX
# dedicated     XXXdedicatedXXX
# nodes         XXXnodesXXX
# extra1        XXXextra1XXX
# extra2        XXXextra2XXX
# extra3        XXXextra3XXX
# extra4        XXXextra4XXX
# extra5        XXXextra5XXX

#SBATCH --job-name=r500perf-gpu
#SBATCH --open-mode=append
#SBATCH --clusters=gmerlin7
#SBATCH --hint=nomultithread
#SBATCH --export=NONE

#SBATCH --partition=XXXqueueXXX
#SBATCH --ntasks=XXXmpinodesXXX
#SBATCH --cpus-per-task=XXXthreadsXXX
#SBATCH --error=XXXerrfileXXX
#SBATCH --output=XXXoutfileXXX
#SBATCH --time=XXXextra1XXX
#SBATCH --nodes=XXXextra3XXX
#SBATCH --mem=XXXextra4XXX
#SBATCH --gres=gpu:XXXextra5XXX
#SBATCH XXXextra2XXX

# Load RELION module
module purge
module load relion/5.0.0-perf

if [ "$(uname -m)" = "x86_64" ]; then
    module load IMOD/5.0.0
fi

# System diagnostics
echo "=== System Information ===" >&2
echo -n "Hostname       => " >&2 && hostname >&2
echo "CPU Model      =>" >&2 && lscpu | grep "Model name" | uniq >&2
echo "Total Memory   =>" >&2 && free -h >&2

# GPU info
if command -v nvidia-smi &>/dev/null; then
    echo "Available GPUs =>" >&2
    nvidia-smi -L >&2
else
    echo "No GPUs available" >&2
fi
echo "==========================" >&2

# OpenMP setup
export OMP_PROC_BIND=close
export OMP_PLACES=cores
export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK}

# Execute RELION
mpirun -np "${SLURM_NTASKS}" \
  --map-by node:PE=${SLURM_CPUS_PER_TASK} \
  --bind-to core --report-bindings \
  XXXcommandXXX
