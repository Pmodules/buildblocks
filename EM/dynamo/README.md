# Dynamo

## Installation

Installation was only partially automated in the build script. Currently only the 'prep' step is implemented. Future versions will add more commands to the build script.

Installation should be done on merlin with an -adm account

1. Add new version to `files/variants`
2. Add google drive download link to `$V/config`.
3. Run `build <version>`
4. module load dynamo/$V
5. `cd $DYNAMO_HOME/bin`. Further steps are taken from `README_dynamo_installation.txt`
6. [Compile stand-alone](https://www.dynamo-em.org/w/index.php?title=Installation)

    dynamo_setup_linux.sh

7. [Compile MPI](https://www.dynamo-em.org/w/index.php?title=MPI_Cluster):
  - With the shipped MCRLinux directory:

    source dynamo_setup_cluster.sh mpic++ dynamo_activate_linux_shipped_MCR.sh

  - With MCR from pmodules:

    source dynamo_setup_cluster.sh mpic++ dynamo_activate_MCR.sh

8. Compile Cuda:

    cd $DYNAMO_ROOT/cuda
    make clean
    ./config.sh
    grep CUDA_ROOT makefile
    make all
    make extended


