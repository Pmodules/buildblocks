# Relion

## Installation

Relion is installed from git. The ./build script should work for both stable
(tags) and unstable (branches) versions. It should be run on Merlin6 from an
admin account.

Currently only gcc is used. Better performance is reported with intel icc
and MKL, but this would require additional openmpi variants.

After running ./build, install relion scripts from the repository at
https://git.psi.ch/lsm-hpce/relion-scripts

From version 5.0-beta on, a conda env is required. conda env is build in the folder $SRC\_DIR/conda\_envs. Also, weights for BLUSH, MODEL-ANGELO and CLASS-RANKER are downloaded in the installation step. 
