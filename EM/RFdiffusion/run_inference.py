#!/bin/bash

# Validate that the RFdiffusion image is specified and exists
if [[ -z "${APPTAINER_IMAGE:-}" || ! -f "$APPTAINER_IMAGE" ]]; then
    echo "Error: RFdiffusion image not found or is not set."
    echo "Please contact the system administrators for assistance."
    exit 1
fi

IMAGE="$APPTAINER_IMAGE"

# Run RFdiffusion inside the Singularity container
singularity exec \
    --nv \
    --bind "/data/scratch/shared:/data/scratch/shared" \
    --bind "/data/user:/data/user" \
    --bind "/data/project:/data/project" \
    --bind "/scratch:/scratch" \
    --bind "/tmp:/tmp" \
    "$IMAGE" \
    python3.9 /app/RFdiffusion/scripts/run_inference.py "$@"
