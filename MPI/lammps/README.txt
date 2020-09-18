[27.08.2020] 
  * With CMake is necessary to have 'python3-virtualenv' installed. Needed for building documentation.
  * Compilation for version 2020.3 with OMP, GCC v8, OpenMPI v4.0.4 works without the need of specifying '-D LAMMPS_OMP_COMPAT=4'
    * More details here: https://lammps.sandia.gov/doc/Build_basics.html)
    * Problems are seen with GCC v9, so is recommended to use GCC v8 for that. It was compiled with v8.
