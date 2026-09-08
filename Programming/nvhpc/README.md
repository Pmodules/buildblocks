After installing PGI, the localrc file of the pgi installation needs to be modified by issuing the following commands in the directory where the localrc file is located:

    module add gcc/<appropriate version>  # currently 7.3.0
    ./makelocalrc -x -gcc $(which gcc) -gpp $(which g++) -g77 $(which gfortran)

