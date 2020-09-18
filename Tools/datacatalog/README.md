# Datacatalog

## Overview 

This module provides tools to interface with the Data Catalog (discovery.psi.ch).

## Installation

Run `./build <VERSION>` to install the latest version. This downloads the
latest versions of the datasetIngestor, datasetRetriever, and datasetArchiver
tools. Note that the downloads are not versioned, so make sure that the current
variant matches the installed binaries.

The `scicat_client` script is also installed. This is maintained as an anaconda
environment, then symlinked into the datacatalog pmodule. Anaconda hard-codes
the correct python interpreter, so all dependencies should resolve even though
the conda module is not activated. See
Programming/anaconda/2019.07/conda-env-defs/scicat_client for environment
installation details.

