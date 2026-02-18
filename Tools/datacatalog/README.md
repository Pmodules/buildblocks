# Datacatalog

## Overview 

This module provides tools to interface with the Data Catalog (discovery.psi.ch).

## Installation

Installation requires Pmodules 2.0 or newer. On ra this must be loaded manually:

```sh
modules purge
modules load Pmodules
```

Update files/config.yaml to add the latest release available on github.

Run `./build <VERSION>` to install the latest version. This downloads the
latest versions of the CLI datasetIngestor, datasetRetriever, and datasetArchiver
tools, as well as installing backwards compatibility scripts.

The file `/opt/psi/Tools/modulefiles/datacatalog/.version`, if present,
controls which version should be loaded if no version is explicitely requested.
This was needed for Pmodules/1.0.0, which didn't ignore unstable versions
properly. If the latest version is stable this file should be renamed to
disable it or updated manually.

### SciCat GUI

The SciCat GUI is currently not included in the distribution (pending fixes for
Scicat v4 compatibility).

# TODO

- [ ] SciCat should be downloaded and installed in the build script. (This is
      planned after the GUI is migrated to github and CI/CD implemented.)

## History

### v1

- Prior to version 2, each command had its own version. The pmodule version
  roughly tracked the datasetIngestor version. However, some pmodules were
  updated manually with more recent binaries, so in general there is no way to
  check the versions contained in older pmodules other than running each
  command and parsing the output.

### v2.2.0

- From v2.2.0 all CLI commands share a common version, and the pmodules will
  reflect this. The SciCat GUI is still versioned independently, but this is
  planned to be brought in sync with the CLI and pmodule soon.
- The `scicat_client` script is also installed. This is maintained as an
  anaconda environment, then symlinked into the datacatalog pmodule. Anaconda
  hard-codes the correct python interpreter, so all dependencies should resolve
  even though the conda module is not activated. See
  `Programming/anaconda/2019.07/conda-env-defs/scicat_client` for environment
  installation details.
- An issue in 2.2.0 and earlier prevents the GUI from running on RHEL 8. This
  was fixed with a manual wrapper script which produces an error on RHEL 8.
- The SciCat GUI is installed manually to `bin`. As of 2.2.0, no standard
  release cycle is used for the GUI. It should be built from source in the
  [rollout repo](https://git.psi.ch/MELANIE/rollout/-/tree/master/Software/00-General/SciCatArchiverGUI)
  and manually copied.


### v3.0.0

- CLI v3 requires SciCat v4. Alpha modules printed a warning during the time
  when production differed from dev. Following 3.0.0 the warning was removed
- Install backwards-compatibility scripts (which print a deprecation warning)
- Remove python `scicat_client`, which doesn't work with Scicat v4
- Remove the GUI, which also doesn't work.

### v3.1.0

- Building now requires Pmodules 2.0 or newer (and uses config.yaml)

