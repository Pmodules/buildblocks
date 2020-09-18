# scicat-client

The scicat-client environment is used in the datacatalog module. Contact
Spencer Bliven, Stephan Egli, or Leo Sala for more info.

## Installing

First, create the conda environment

    conda env create -f scicat_client.yml

Next, install scicat_client. Eventually this should be done automatically
through conda, but for now it needs to be installed from source.

    git clone git@github.com:paulscherrerinstitute/scicat_client.git
    cd scicat_client
    conda activate scicat_client-0.1.0
    python setup.py install


