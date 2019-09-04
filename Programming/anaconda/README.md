# Building of an Anaconda release using Pmodules

## Concepts

   * The anaconda module just provides the **conda** package management tool together with its directory infrastructure which contains *conda environments* and a cache of downloaded packages
   * Python and user software is provided in **conda environments**. These environments are located within the directory tree belonging to the anaconda module, e.g. `/afs/psi.ch/sys/psi.merlin/Programming/anaconda/2019.03/conda/envs/`
   * The software in these environments can be accessed by users through
      1) loading the anaconda module and then using `conda activate somemodule_py36`
	  1) a seperate pmodule that transparently switches to that installed environment by just setting the correct PATH to the python binary.
	  1) jupyter installations running from one of the environments which discover the other environments if they contain the correct packages (**nb_conda_kernels**)
   * The `conda` tool has frequent updates, and our experience shows that they should be installed. However, it would be a waste to every time produce a new module, because with the new module would also be associated a new area for environments. So, we prefer to update conda in place, and only make a new anaconda module if their are special incentives
   * Most environments are self sufficient and do not depend on the conda tool at all after the instalation: Conda took care of installing all depending libraries, and the builds that conda provides make consistent use of **rpath** definitions for executables and libraries, i.e. there is no reason to set `LD_LIBRARY_PATH` at all.
      * There is one important exception: If your environment needs additional setups (activation hooks), then it will rely on the `conda activate` call, since these hooks are only run inside of this call.
   
## Building a central conda environment

   * **Allways work on the host pmod6**: conda is trying to use hardlinks where it can. There is an issue that can appear if you install from a machine that uses Auristor (which provides hardlinks). This causes whole environments to become corrupt, so that only a PSI AFS admin can fix the problem. Therefore we only install from pmod6 which runs openAFS.

### installation of a pure conda environment

In the simplest case, the environment can be created by conda alone. First load the anaconda module to get access to the conda package installer and the install environment.

```
module load anaconda/2019.03
```

Define your installation in a `conda YAML` file and place it inside the buildblock
tree

```
cd buildblocks/Programming/anaconda/2019.03/conda-env-defs
mkdir datascience_36
vim datascience_36/datascience_36.yml
``` 

Create the environment
```
conda env create -f datascience_36/datascience_36.yml
```

### installation of a conda environment and adding pip packages

Frequently there are packages that are not available as conda packages, even though they may exist as PyPi packages. You have two options
   1. install the dependencies using `pip`
   1. create a conda package based on the PyPi package

In most cases you will want to go ahead with `pip` installs. However, after running `pip` inside of a conda environment, the environment is tainted and conda may warn you that it is inconsistent. Therefore conda packages should always be installed first.

Proceed as above by defining a YAML file and use conda to first install all the conda based packages.

Even though the YAML file also allows for the specification of pip packages, I advise to do this step separately. The pip steps can fail for various reasons, and it is better to do them interactively. Describe what you have to do in a README.md inside of the `conda-env-defs/${myenv}** folder.

**Note** that if pip triggers compilations, the package may pick up shared libraries from outside the environment. This can lead to problems if the build is done on pmod6.psi.ch which runs SL6, while most of the production environments are now on REHL7!

   
### installation of a conda environment and adding source compiled packages

**This is still a DRAFT!!!**

This works if the python package has a correct setup.py build

   * If you need to apply changes to the source
      * Clone the relevant git repos on github/gitlab
      * implement your changes in a branch
	  * document it in `conda-env-defs/${myenv}/README.md`
   * downlad and store the sources in the install area under
     `/opt/psi/Programming/anaconda/2019.07/xxxx/mypackage`
   * Use pip to install them into the environment (requires that the package comes with a correct `setup.py`)
     ```
     cd /opt/psi/Programming/anaconda/2019.07/xxxx/mypackage
     pip install .
     ```
