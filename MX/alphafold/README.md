# Alphafold

Alphafold contains two parts:
1. A conda environment containing dependencies
2. The alphafold module itself, containing the current code and submission scripts.

## Conda Environment

Alphafold was installed based on Dima's instructions on ra
(`/das/work/common/opt/alphafold/2021-07/INSTALL`).

On pmod6 as an admin user:

```
conda create --name alphafold python==3.8
conda update -n base conda

source miniconda3/etc/profile.d/conda.sh
conda activate alphafold

conda install -y -c conda-forge openmm==7.5.1 cudnn==8.2.1.32 cudatoolkit==11.0.3 pdbfixer==1.7
conda install -y -c bioconda hmmer==3.3.2 hhsuite==3.3.0 kalign2==2.04

pip install absl-py==0.13.0 biopython==1.79 chex==0.0.7 dm-haiku==0.0.4 \
    dm-tree==0.1.6 immutabledict==2.0.0 jax==0.2.14 ml-collections==0.1.0 \
    numpy==1.19.5 scipy==1.7.0 tensorflow==2.5.0
pip install --upgrade jax jaxlib==0.1.69+cuda111 \
    -f https://storage.googleapis.com/jax-releases/jax_releases.html
```

If this needs to be updated in the future we may need to have versioned conda envs.

## Alphafold module

Add version to files/variants. The version number should match a github tag
(e.g. `v2.0.1`) or else have the commit hash as `$V_RELEASE`.

As admin user:
```
cd MX/alphafold
./build <version>
```

## Testing

Here's an example sequence:

```
mkdir example
cd example
cat > query.fasta <<EOF
>dummy_sequence
GWSTELEKHREELKEFLKKEGITNVEIRIDNGRLEVRVEGGTERLKRFLEELRQKLEKKGYTVDIKIE
EOF

module use MX unstable
module load alphafold/2.0.1
sbatch $ALPHAFOLD_DIR/bin/submit_merlin.sh query.fasta
```

