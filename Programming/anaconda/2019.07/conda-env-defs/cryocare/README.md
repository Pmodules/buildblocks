# INSTALLATION

IMPORTANT! DON'T INSTALL WITH AURISTOR. Use an OpenAFS system (e.g. pmod6)

    CONDA_COPY_ALWAYS=1 conda env create --file cryocare.yml
    conda activate cryocare

Now configure jupyter

    cp share/jupyter/kernels/python3/kernel.json $CONDA_PREFIX/share/jupyter/kernels/python3/
    cp etc/conda/activate.d/cryocare-env.sh $CONDA_PREFIX/etc/conda/activate.d/
    cp etc/conda/deactivate.d/cryocare-env.sh $CONDA_PREFIX/etc/conda/deactivate.d/

## Package notes

- cudatoolkit version is fixed because it needs to match merlin6's CUDA module
  (required by the MotionCor2 package).
- This environment installs packages for gpu support, but these currently don't
  seem to be working on merlin.

