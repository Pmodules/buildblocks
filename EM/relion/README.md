# Relion

## Installation

Relion is installed from git. The ./build script should work for both stable
(tags) and unstable (branches) versions. It should be run on Merlin6 from an
admin account.

Currently only gcc is used. Better performance is reported with intel icc
and MKL, but this would require additional openmpi variants.

After running ./build, install relion scripts from the repository at
https://git.psi.ch/lsm-hpce/relion-scripts

## Important info per version!

### 5.0-beta (OLD, Merlin6)
- From version 5.0-beta on, a conda env is required (done with central anaconda module, needs to be done on pmod7 because of AFS hardlinks)
- the conda env is build in the folder $SRC\_DIR/conda\_envs. Also, weights for BLUSH, MODEL-ANGELO and CLASS-RANKER are downloaded in the installation step. 

### 5.0-1beta (OLD, Merlin6)
- the conda env is made with a miniconda installation, and because of upgrading to Pmodules/1.1.21 , the variants file was dropped and changed into the config.yaml file. 
- The build script was also updated accordingly
- Also, cryocare is now available in a wrapper from relion, the cryocare installation executables need to be provided (seperate cryocare module). It is crucial to add the cryocare lib path (from the cryocare conda env)  to the LD_LIBRARY_PATH when loading the relion module
- tiff module no longer required, as this conflicts with the system shared tiff libs (not 100% sure why this canged from previous installations though)
### 5.0-2beta (ON MERLIN7)
- no fetching of weights with ftp possible, so cp from other machines into BUILD DIR and using the -DFETCH\_WEIGHTS=OFF option
- link : ftp://ftp.mrc-lmb.cam.ac.uk/pub/scheres/fltk-1.3.5-source.tar.gz 
- link : ftp://ftp.mrc-lmb.cam.ac.uk/pub/dari/classranker\_v1.0.ckpt.gz 

### 5.0.0 A100
- same as 5.0-2beta (especially when it comes to the weights...)
- copy the fltk and the classranker file into the BUILD Directory. The build script assumes that these two files are in the BUILD\_DIR.   
- sha256 errors occured during installation: 
```
ERROR: THESE PACKAGES DO NOT MATCH THE HASHES FROM THE REQUIREMENTS FILE. If you have updated the package versions, please update the hashes. Otherwise, examine the package contents carefully; someone may have tampered with them.
    unknown package:
        Expected sha256 20abd2cae58e55ca1af8a8dcf43293336a59adf0391f1917bf8518633cfc2cdf
             Got        e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
```
- The download of some packages (.whl files) was blocked by the merlin7 firewall. Google the shasum and find the package name. Try to manually download with curl. If this fails, this is a strong indication for network/firewall issues that need to be adressed by the networking team. .whl files from conda +pip installations are ususally stored in the env in lib/pythonXXX.
- Also, to not clean up build directories: 
```
--no-clean
Don't clean up build directories.
(environment variable: PIP_NO_CLEAN)

```
### 5.0.0 for GH 

no successful installation so far - failing for conda env. Elsa G. build some hacky hack that works kind of.. 
needs to be investigated further. 

