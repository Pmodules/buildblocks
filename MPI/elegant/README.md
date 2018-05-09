# How to compile (P)elegant

## Official build instructions

>
Go down for PSI build instructions!

Instructions to setup `epics/base`, `epics/extensions` compile `SDDS` and `elegant`. The instructions to build from source are almost at the end of the page:

https://www.aps.anl.gov/Accelerator-Operations-Physics/Software/installationGuide_Linux

Instructions to build `Pelegant`:

https://ops.aps.anl.gov/publish/Pelegant_manual/node2.html

## Get the software

**Main page**

* https://www1.aps.anl.gov/Accelerator-Operations-Physics/Software

**Configuration files for EPICS build system (base and extensions)**

* http://www.aps.anl.gov/Accelerator_Systems_Division/Accelerator_Operations_Physics/cgi-bin/oagLog4.cgi?name=epics.base.configure.tar.gz
* http://www.aps.anl.gov/Accelerator_Systems_Division/Accelerator_Operations_Physics/cgi-bin/oagLog4.cgi?name=epics.extensions.configure.tar.gz

**Configure files for elegant, spiffe, genesis, and shower**

* http://www.aps.anl.gov/Accelerator_Systems_Division/Accelerator_Operations_Physics/cgi-bin/oagLog4.cgi?name=oag.apps.configure.tar.gz

**SDDS source**

* http://www.aps.anl.gov/Accelerator_Systems_Division/Accelerator_Operations_Physics/cgi-bin/oagLog4.cgi?name=SDDS.3.6.1.tar.gz

**elegant source**

* http://www.aps.anl.gov/Accelerator_Systems_Division/Accelerator_Operations_Physics/cgi-bin/oagLog4.cgi?name=elegant.34.2.0.tar.gz

## Required Modules

```
module load gcc/7.3.0 gsl/2.4 mpich/3.2.1
```

## Setup Environment
```
DOWNLOAD_DIR='/afs/psi.ch/software/Pmodules/distfiles/elegant'
PREFIX=/opt/psi/MPI/elegant/34.2.0/mpich/3.2.1/gcc/7.3.0

export HOST_ARCH=linux-x86_64
export EPICS_HOST_ARCH=linux-x86_64
export RPN_DEFNS="${PREFIX}/RPN_DEFNS/defns.rpn
```

## Prepare build environment

EPICS base configuration
```
mkdir -p "${PREFIX}"
cd "${PREFIX}"
tar xvf "${DOWNLOAD_DIR}/epics.base.configure.tar.gz"
cd epics/base
make
```

Prepare configuration files for EPICS build system
```
cd "${PREFIX}"
tar xvf "${DOWNLOAD_DIR}/epics.extensions.configure.tar.gz 
```

Prepare configuration files for elegant and other OAG apps
```
cd "${PREFIX}"
tar xvf "${DOWNLOAD_DIR}/oag.apps.configure.tar.gz 
```

## Base configuration for SDDS and elegant
```
ARGS=()
ARGS+=( "AR=ar -rc" )
ARGS+=( "LD=ld -r" )
ARGS+=( "RANLIB=ranlib" )
ARGS+=( "GNU_DIR=${GCC_DIR}" )
ARGS+=( "CLAPACK_LIB=${ATLAS_LIBRARY_DIR}" )
ARGS+=( "ATLAS_LIB=${ATLAS_LIBRARY_DIR}" )
ARGS+=( "ATLAS_INCLUDE=${ATLAS_INCLUDE_DIR}" )
ARGS+=( "SYSGSL=1" )
ARGS+=( "LAPACK=0" )
ARGS+=( "GFORTRAN=1" )
ARGS+=( "CLAPACK=1" )
ARGS+=( "EPICS_BASE=${PREFIX}/epics/base" )
ARGS+=( "INSTALL_LOCATION=${PREFIX}" )
ARGS+=( "INSTALL_LIB=${PREFIX}/lib" )
ARGS+=( "INSTALL_SHRLIB=${PREFIX}/lib" )
ARGS+=( "INSTALL_TCLLIB=${PREFIX}/lib" )
ARGS+=( "INSTALL_BIN=${PREFIX}/bin" )
```

== Compile SDDS
```
cd ${PREFIX}/epics/extensions/src/SDDS/
make "${ARGS[@]}" OP_SYS_LDLIBS="-lgfortran -lquadmath -lf2c" -C png
make "${ARGS[@]}" OP_SYS_LDLIBS="-lgfortran -lquadmath -lf2c" -C pgapack
make "${ARGS[@]}" OP_SYS_LDLIBS="-lgfortran -lquadmath -lf2c"
make "${ARGS[@]}" OP_SYS_LDLIBS="-lgfortran -lquadmath -lf2c" MPI=1 -C SDDSlib
```

== Compile elegant
```
PATH+=":${PREFIX}/bin"

cd "${PREFIX}/oag/apps/src/physics"
make "${ARGS[@]}" OP_SYS_LDLIBS="-lreadline -lncurses -lgfortran -lquadmath -lf2c -lm -lrt -ldl"

cd "${PREFIX}/oag/apps/src/xraylib"
make "${ARGS[@]}" OP_SYS_LDLIBS="-lreadline -lncurses -lgfortran -lquadmath -lf2c -lm -lrt -ldl"

cd "${PREFIX}/oag/apps/src/elegant"
make "${ARGS[@]}" OP_SYS_LDLIBS="-lreadline -lncurses -lgfortran -lquadmath -lf2c -lm -lrt -ldl"
make "${ARGS[@]}" OP_SYS_LDLIBS="-lreadline -lncurses -lgfortran -lquadmath -lf2c -lm -lrt -ldl" Pelegant
make "${ARGS[@]}" OP_SYS_LDLIBS="-lreadline -lncurses -lgfortran -lquadmath -lf2c -lm -lrt -ldl" -C elegantTools
make "${ARGS[@]}" OP_SYS_LDLIBS="-lreadline -lncurses -lgfortran -lquadmath -lf2c -lm -lrt -ldl" -C sddsbrightness
```
