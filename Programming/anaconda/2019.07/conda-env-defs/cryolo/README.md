# INSTALLATION

IMPORTANT! DON'T INSTALL WITH AURISTOR. Use an OpenAFS system (e.g. pmod6)

    export TMPDIR=/opt/tmp/$USER
    export XDG_CACHE_HOME=/opt/tmp/$USER/.cache
    CONDA_COPY_ALWAYS=1 conda env create --file cryolo.yml
    conda activate cryolo

The alternate TMPDIR is required on pmod6 because /tmp is too small for pip to expand all wheel files.

