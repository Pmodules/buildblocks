# Datacatalog

## Overview 

This module provides tools to interface with the Data Catalog (discovery.psi.ch).

## Version Numbers

Prior to version 2, each command had its own version. The pmodule version
roughly tracked the datasetIngestor version. However, some pmodules were
updated manually with more recent binaries, so in general there is no way to
check the versions contained in older pmodules other than running each command
and parsing the output.

From v2.2.0 all CLI commands share a common version, and the pmodules will
reflect this. The SciCat GUI is still versioned independently, but this is
planned to be brought in sync with the CLI and pmodule soon.

## Installation

Run `./build <VERSION>` to install the latest version. This downloads the
latest versions of the datasetIngestor, datasetRetriever, and datasetArchiver
tools.

The `scicat_client` script is also installed. This is maintained as an anaconda
environment, then symlinked into the datacatalog pmodule. Anaconda hard-codes
the correct python interpreter, so all dependencies should resolve even though
the conda module is not activated. See
`Programming/anaconda/2019.07/conda-env-defs/scicat_client` for environment
installation details.

The file `/opt/psi/Tools/modulefiles/datacatalog/.version`, if present,
controls which version should be loaded if no version is explicitely requested.
This was needed for Pmodules/1.0.0, which didn't ignore unstable versions
properly. If the latest version is stable this file should be renamed to
disable it.

### SciCat GUI

The SciCat GUI is installed manually to `bin`. As of 2.2.0, no standard release
cycle is used for the GUI. It should be built from source in the [rollout
repo](https://git.psi.ch/MELANIE/rollout/-/tree/master/Software/00-General/SciCatArchiverGUI)
and manually coppied.

An issue in 2.2.0 and earlier prevents the GUI from running on RHEL 8. This was
fixed with a manual wrapper script which produces an error on RHEL 8.

# TODO

- [ ] SciCat should be downloaded and installed in the build script. (This is
      planned after the GUI is migrated to github and CI/CD implemented.)

