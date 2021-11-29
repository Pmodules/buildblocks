# Building a module for (P)elegant

## Home page and official build instructions

Elgant is a software packages produced by the [Accelerator Operations
and Physics Group](https://www.aps.anl.gov/Accelerator-Operations-Physics/Software).
It requires the EPICS build-system and SDDS. The EPICS build-system is completely 
based on Makefiles. This makes it a bit harder to compile and more error prone. 

Instructions to setup `epics/base`, `epics/extensions` and to compile `SDDS` as
well as `elegant` can be found 
[here](https://www.aps.anl.gov/Accelerator-Operations-Physics/Software/installationGuide_Linux).
The instructions to build from source are almost at the end of the page.

Instructions to build [`Pelegant`](https://ops.aps.anl.gov/publish/Pelegant_manual/node2.html)

## Getting required configuration files

* [file defining constants and some functions](https://ops.aps.anl.gov/cgi-bin/oagLog4.cgi?name=defns.rpn)
* [EPICS base configuration](http://www.aps.anl.gov/Accelerator_Systems_Division/Accelerator_Operations_Physics/cgi-bin/oagLog4.cgi?name=epics.base.configure.tar.gz)
* [EPICS extensions configuration](http://www.aps.anl.gov/Accelerator_Systems_Division/Accelerator_Operations_Physics/cgi-bin/oagLog4.cgi?name=epics.extensions.configure.tar.gz)
* [Configuration files for elegant, spiffe, genesis, and shower](http://www.aps.anl.gov/Accelerator_Systems_Division/Accelerator_Operations_Physics/cgi-bin/oagLog4.cgi?name=oag.apps.configure.tar.gz)

## Elegant 2021.4.0

### SDDS 5 and Elegant 2021.4 sources

* [SDDS 5.1 source](https://ops.aps.anl.gov/cgi-bin/oagLog4.cgi?name=SDDS.5.1.tar.gz)
* [Elegant 2021.4.0 source](http://www.aps.anl.gov/Accelerator_Systems_Division/Accelerator_Operations_Physics/cgi-bin/oagLog4.cgi?name=elegant.2021.4.0.tar.gz)

### Required Modules

```
module load gcc/10.3.0 gsl/2.7 lapack/3.10.0 openmpi/4.0.5
```


### Setup Environment
```
SDDS_VERSION=5.1
ELEGANT_VERSION=2021.4.0
source "${PMODULES_ROOT}/config/modbuild.conf"
DOWNLOAD_DIR="${PMODULES_DISTFILESDIR}/elegant"
PREFIX="${PMODULES_ROOT}/MPI/elegant/${ELEGANT_VERSION}/${MPI}/${MPI_VERSION}/${COMPILER}/${COMPILER_VERSION}"

export EPICS_BASE="${PREFIX}/epics/base"
export HOST_ARCH=linux-x86_64
export EPICS_HOST_ARCH=linux-x86_64
export RPN_DEFNS="${PREFIX}/RPN_DEFNS/defns.rpn"
export PERLLIB="${PREFIX}/lib/perl"

PATH+=":$PREFIX/epics/extensions/bin/${EPICS_HOST_ARCH}"

ARGS=()
ARGS+=( "GNU_BIN=$GCC_DIR/bin" )
ARGS+=( "LD=/usr/bin/ld" )
ARGS+=( "AR=/usr/bin/ar -rc" )
ARGS+=( "RANLIB=/usr/bin/ranlib" )
ARGS+=( "SYSGSL=1")
```

### Prepare everything

```
mkdir -p "${PREFIX}"
mkdir -p "${RPN_DEFNS%/*}"
cp "${DOWNLOAD_DIR}/defns.rpn" "${RPN_DEFNS}"
cd "${PREFIX}"
tar xvf "${DOWNLOAD_DIR}/epics.base.configure.tar.gz"
tar xvf "${DOWNLOAD_DIR}/epics.extensions.configure.tar.gz"
tar xvf "${DOWNLOAD_DIR}/oag.apps.configure.tar.gz"
tar xvf "${DOWNLOAD_DIR}/SDDS.${SDDS_VERSION}.tar.gz"
tar xvf "${DOWNLOAD_DIR}/elegant.${ELEGANT_VERSION}.tar.gz"
```

### Configure EPICS base and OAG applications

```
cd epics/base
make "${ARGS[@]}"
cd "${PREFIX}/oag/apps/configure"
sed -i "s/clean::/clean:/" RULES_PYTHON
make "${ARGS[@]}"
```

### Compile SDDS 5.1

```
cd "${PREFIX}/epics/extensions/src/SDDS/"
sed -i -e  "s/\( sddspseudoinverse_SYS_LIB.*\)/\1 gfortran/" SDDSaps/pseudoInverse/Makefile
sed -i -e  "s/\( sddsmatrixop_SYS_LIBS.*\)/\1 gfortran/" SDDSaps/pseudoInverse/Makefile

make "${ARGS[@]}" -C png   && \
make "${ARGS[@]}"

make "${ARGS[@]}" -C fftpack
make "${ARGS[@]}" -C pgapack
make "${ARGS[@]}" -C namelist
make "${ARGS[@]}" -C matlib
make "${ARGS[@]}" -C mdbcommon
make "${ARGS[@]}" -C mdblib
```

### Compile elegant 2021.4.0

```
cd "${PREFIX}/oag/apps/src/elegant"
make "${ARGS[@]}" STATIC_BUILD=NO
```

### Compile Pelegant 2021.4.0

```
cd "${PREFIX}/epics/extensions/src/SDDS/"
make "${ARGS[@]}" -C SDDSlib clean
make "${ARGS[@]}" MPI=1 -C SDDSlib

cd "${PREFIX}/oag/apps/src/elegant"
make clean
make SYSGSL=1 Pelegant
```


## Elegant 2020.2.0

### SDDS and Elegant sources

* [SDDS 4.3.1 source](http://www.aps.anl.gov/Accelerator_Systems_Division/Accelerator_Operations_Physics/cgi-bin/oagLog4.cgi?name=SDDS.4.3.0.tar.gz)
* [Elegant 2020.2.0 source](http://www.aps.anl.gov/Accelerator_Systems_Division/Accelerator_Operations_Physics/cgi-bin/oagLog4.cgi?name=elegant.2020.2.0.tar.gz)

### Required Modules

```
module load gcc/8.4.0 gsl/2.6 OpenBLAS/0.3.10 mpich/3.2.1
```
or
```
module load gcc/8.4.0 gsl/2.6 lapack/3.9.0 openmpi/3.1.6
```


### Setup Environment
```
SDDS_VERSION=4.3
ELEGANT_VERSION=2020.2.0
source "${PMODULES_ROOT}/config/modbuild.conf"
DOWNLOAD_DIR="${PMODULES_DISTFILESDIR}/elegant"
PREFIX="${PMODULES_ROOT}/MPI/elegant/${ELEGANT_VERSION}/${MPI}/${MPI_VERSION}/${COMPILER}/${COMPILER_VERSION}"

export EPICS_BASE="${PREFIX}/epics/base"
export HOST_ARCH=linux-x86_64
export EPICS_HOST_ARCH=linux-x86_64
export RPN_DEFNS="${PREFIX}/RPN_DEFNS/defns.rpn"
export PERLLIB="${PREFIX}/lib/perl"

PATH+=":$PREFIX/epics/extensions/bin/${EPICS_HOST_ARCH}"

ARGS=()
ARGS+=( "GNU_BIN=$GCC_DIR/bin" )
ARGS+=( "LD=/usr/bin/ld" )
ARGS+=( "AR=/usr/bin/ar -rc" )
ARGS+=( "RANLIB=/usr/bin/ranlib" )
ARGS+=( "SYSGSL=1")
```

### Prepare everything

```
mkdir -p "${PREFIX}"
mkdir -p "${RPN_DEFNS%/*}"
cp "${DOWNLOAD_DIR}/defns.rpn" "${RPN_DEFNS}"
cd "${PREFIX}"
tar xvf "${DOWNLOAD_DIR}/epics.base.configure.tar.gz"
tar xvf "${DOWNLOAD_DIR}/epics.extensions.configure.tar.gz"
tar xvf "${DOWNLOAD_DIR}/oag.apps.configure.tar.gz"
tar xvf "${DOWNLOAD_DIR}/SDDS.${SDDS_VERSION}.tar.gz"
tar xvf "${DOWNLOAD_DIR}/elegant.${ELEGANT_VERSION}.tar.gz"
```

### Configure EPICS base and OAG applications

```
cd epics/base
make "${ARGS[@]}"
cd "${PREFIX}/oag/apps/configure"
sed -i "s/clean::/clean:/" RULES_PYTHON
make "${ARGS[@]}"
```

### Compile SDDS

```
cd "${PREFIX}/epics/extensions/src/SDDS/"
sed -i -e  "s/\( sddspseudoinverse_SYS_LIB.*\)/\1 gfortran/" SDDSaps/pseudoInverse/Makefile
sed -i -e  "s/\( sddsmatrixop_SYS_LIBS.*\)/\1 gfortran/" SDDSaps/pseudoInverse/Makefile

make "${ARGS[@]}" -C png   && \
make "${ARGS[@]}"

make "${ARGS[@]}" -C pgapack
make "${ARGS[@]}" -C SDDSlib clean
make "${ARGS[@]}" MPI=1 -C SDDSlib
```

### Compile elegant

```
cd "${PREFIX}/oag/apps/src/elegant"
make "${ARGS[@]}" STATIC_BUILD=NO
```

### Compile Pelegant

```
cd "${PREFIX}/oag/apps/src/elegant"
make clean
make SYSGSL=1 Pelegant
```
