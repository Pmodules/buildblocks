# ColabFold
ColabFold offers accelerated prediction of protein structures and complexes by combining the fast homology search of MMseqs2 with AlphaFold2 or RoseTTAFold. ColabFold’s 40−60-fold faster search and optimized model utilization enables prediction of close to 1,000 structures per day on a server with one graphics processing unit. Coupled with Google Colaboratory, ColabFold becomes a free and accessible platform for protein folding.

https://github.com/sokrypton/ColabFold

## Installation
The ColabFold installation is performed by downloading the pre-build docker image available in their github repository:

1. Pull the docker image and convert into a .sif singularity file.
```bash
singularity pull docker://ghcr.io/sokrypton/colabfold:1.5.5-cuda12.2.2
```

2. Set the environamental variable APPTAINER_IMAGE to the directory where the .sif file is located.
Also set the variable MODEL_WEIGHTS_DIR to the directory of where the model weights are stored.
`setenv APPTAINER_IMAGE /data/project/bio/shared/containers/colabfold/1.5.5/colabfold_1.5.5-cuda12.2.2.sif`
`setenv MODEL_WEIGHTS_DIR /data/project/bio/shared/alphafold/versions/v2.3.2/latest`

3. Build the module.
