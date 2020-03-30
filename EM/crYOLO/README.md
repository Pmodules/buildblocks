# crYOLO

crYOLO/1.2.3 was built as a miniconda independent environment.
Subsequent versions are deployed as central conda environments.
This significantly changed the build process.

## Adding New Versions

To add a new version, first create the conda environment, as described in
../../Programming/anaconda/2019.07/conda-env-defs/cryolo/.

Next, update files/variants with the new version and run `./build <VERSION>` to
install the modulefile

