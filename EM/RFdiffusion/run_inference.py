#!/bin/bash

# Validate that the RFdiffusion image is specified and exists
if [[ -z "${APPTAINER_IMAGE:-}" || ! -f "$APPTAINER_IMAGE" ]]; then
    echo "Error: RFdiffusion image not found or is not set."
    echo "Please contact the system administrators for assistance."
    exit 1
fi

IMAGE="$APPTAINER_IMAGE"

# Default model dir if not overridden via CLI
MODEL_DIRECTORY_PATH="${MODEL_DIRECTORY_PATH:-}"
MODEL_DIRECTORY_PATH_SET=0

# Default output dir if not overridden
OUTPUT_PREFIX="${OUTPUT_PREFIX:-./outputs}"
SCHEDULE_DIRECTORY_PATH="${SCHEDULE_DIRECTORY_PATH:-}"

# Flags to track CLI overrides
OUTPUT_PREFIX_SET=0
SCHEDULE_DIRECTORY_PATH_SET=0

# Parse CLI arguments for user-defined values
ARGS=()
prev_arg=""
for arg in "$@"; do
    if [[ "$prev_arg" == "inference.model_directory_path" ]]; then
        MODEL_DIRECTORY_PATH="$arg"
        MODEL_DIRECTORY_PATH_SET=1
        prev_arg=""
        continue
    elif [[ "$prev_arg" == "inference.output_prefix" ]]; then
        OUTPUT_PREFIX="$arg"
        OUTPUT_PREFIX_SET=1
        prev_arg=""
        continue
    elif [[ "$prev_arg" == "inference.schedule_directory_path" ]]; then
        SCHEDULE_DIRECTORY_PATH="$arg"
        SCHEDULE_DIRECTORY_PATH_SET=1
        prev_arg=""
        continue
    fi

    case "$arg" in
        inference.model_directory_path=*)
            MODEL_DIRECTORY_PATH="${arg#*=}"
            MODEL_DIRECTORY_PATH_SET=1
            ;;
        inference.output_prefix=*)
            OUTPUT_PREFIX="${arg#*=}"
            OUTPUT_PREFIX_SET=1
            ;;
        inference.schedule_directory_path=*)
            SCHEDULE_DIRECTORY_PATH="${arg#*=}"
            SCHEDULE_DIRECTORY_PATH_SET=1
            ;;
        inference.model_directory_path|inference.output_prefix|inference.schedule_directory_path)
            prev_arg="$arg"
            continue
            ;;
    esac

    ARGS+=("$arg")
done

# Only validate MODEL_DIRECTORY_PATH if not overridden via CLI
if [[ $MODEL_DIRECTORY_PATH_SET -eq 0 ]]; then
    if [[ -z "$MODEL_DIRECTORY_PATH" || ! -d "$MODEL_DIRECTORY_PATH" ]]; then
        echo "Error: Default inference.model_directory_path is not set or the directory does not exist."
        echo "Provide a valid path to inference.model_directory_path"
        echo "or contact the system administrators for assistance."
        exit 1
    fi
fi

# If schedule path is not set explicitly, mirror output prefix
if [[ $SCHEDULE_DIRECTORY_PATH_SET -eq 0 ]]; then
    SCHEDULE_DIRECTORY_PATH="$OUTPUT_PREFIX"
fi

# Construct arguments that can be overridden via CLI
INFERENCE_ARGS=(
    "inference.model_directory_path=$MODEL_DIRECTORY_PATH"
    "inference.output_prefix=$OUTPUT_PREFIX"
    "inference.schedule_directory_path=$SCHEDULE_DIRECTORY_PATH"
)

# Run the container with RFdiffusion
singularity exec \
    --nv \
    --bind "/data/scratch/shared:/data/scratch/shared" \
    --bind "/data/user:/data/user" \
    --bind "/data/project:/data/project" \
    --bind "/scratch:/scratch" \
    --bind "/tmp:/tmp" \
    --bind "/etc/ssl/ca-bundle.pem:/etc/ssl/ca-bundle.pem" \
    "$IMAGE" \
    python3.9 /app/RFdiffusion/scripts/run_inference.py "${INFERENCE_ARGS[@]}" "${ARGS[@]}"
