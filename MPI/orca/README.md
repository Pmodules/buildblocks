# How To Install ORCA

## Download the proper ORCA version

Different ORCA version can be downloaded from https://orcaforum.kofo.mpg.de/app.php/dlext/
To download the software, one must be registered with a PSI account.

For Linux, two different packages are available:
1. ORCA with dynamically linked serial & parallel binaries linked against OpenMPI vX.Y.Z
2. ORCA with static serial & parallel binaries linked against OpenMPI vX.Y.Z

For the installation, we will choose the second option: **Static serial & parallel binaries linked against OpenMPI vX.Y.Z**.

## Steps

1. Download the required ORCA version packages (static serial & parallel binaries linked against OpenMPI vX.Y.Z)
2. ORCA must be used with a OpenMPI version, therefore, we need to create the proper structure for that module.
   * In example, for `orca/5.0.3`, we will use it with `gcc/11.2.0 openmpi/4.1.3_slurm`.
   * Therefore, we must create a directory as follows: `mkdir -p /opt/psi/MPI/orca/5.0.3/openmpi/4.1.3_slurm/gcc/11.2.0/share`
3. Extract the contents of ORCA tar files to the corresponding directory in ` /opt/psi/MPI/orca/$version/openmpi/4.1.3_slurm/gcc/11.2.0`
4. Run the post-installation step

## Post-Installation step

1. Add the new version in the variants file, including `openmpi` dependencies:
   ```bash
   (base) [caubet_m-adm@merlin-l-001 orca]# git diff files/variants.rhel7
   orca/5.0.3     unstable   gcc/11.2.0 openmpi/4.1.3_slurm
   ```
2. Update Module files:
   ```bash
   (base) [caubet_m-adm@merlin-l-001: orca]# ./build 5.0.3 --system=merlin6 --update-modulefiles 
   orca/5.0.3: with gcc/11.2.0 openmpi/4.1.3_slurm building ... 
   Loading module: gcc/11.2.0
   Loading module: openmpi/4.1.3_slurm
   module load: unstable module has been loaded -- openmpi/4.1.3_slurm
   orca/5.0.3: with gcc/11.2.0 openmpi/4.1.3_slurm already exists, not rebuilding ... 
   orca/5.0.3: installing modulefile '/opt/psi/MPI/modulefiles/gcc/11.2.0/openmpi/4.1.3_slurm/orca/5.0.3' ... 
   * * * * *
   ```
3. Add `.info` file
   ```bash
   (base) [caubet_m-adm@merlin-l-001 orca]# cat /opt/psi/MPI/orca/5.0.3/openmpi/4.1.3_slurm/gcc/11.2.0/.info 
   ORCA is only allowed to be used for PSI's own internal, non-commercial
   scientific activities.
   
   Each user (employees, contractors, students) must register on the ORCA
   website (https://orcaforum.kofo.mpg.de/app.php/portal) with a PSI Email
   address.
   
   For further information, please read:
   /opt/psi/MPI/orca/5.0.3/openmpi/4.1.3_slurm/gcc/11.2.0/bin/EULA_ORCA_2021.pdf
   ```
3. Commit + push:
4. Request merge request from the provided URL
