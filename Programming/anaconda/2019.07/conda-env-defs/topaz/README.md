# Topaz

[Topaz](https://github.com/tbepler/topaz) is a conda-based cryoEM particle
picker. It is used primarily through cryosparc, but also provides python
notebooks.

See https://intranet.psi.ch/en/bio/computing-cryosparc

## INSTALLATION

IMPORTANT! DON'T INSTALL WITH AURISTOR. Use an OpenAFS system (e.g. pmod6)

    export TMPDIR=/opt/tmp/$USER
    export XDG_CACHE_HOME=/opt/tmp/$USER/.cache
    CONDA_COPY_ALWAYS=1 conda env create --file topaz.yml
    conda activate topaz-0.2.5

The alternate TMPDIR is required on pmod6 because /tmp is too small for pip to expand all wheel files.

