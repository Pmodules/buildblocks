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
module load gcc/7.3.0 gsl/2.4 OpenBLAS/0.2.20 mpich/3.2.1
```

## Set used versions
```
SDDS_VERSION=3.6.1
ELEGANT_VERSION=34.2.0
```

## Setup Environment
```
source "${PMODULES_ROOT}/config/modbuild.conf"
DOWNLOAD_DIR="${PMODULES_DISTFILESDIR}/elegant"
PREFIX="${PMODULES_ROOT}/MPI/elegant/${ELEGANT_VERSION}/${MPI}/${MPI_VERSION}/${COMPILER}/${COMPILER_VERSION}"

export EPICS_BASE="${PREFIX}/epics/base"
export HOST_ARCH=linux-x86_64
export EPICS_HOST_ARCH=linux-x86_64
export RPN_DEFNS="${PREFIX}/RPN_DEFNS/defns.rpn"
export PERLLIB="${PREFIX}/lib/perl"
```

```
ARGS=()
ARGS+=( "GNU_BIN=$GCC_DIR/bin" )
ARGS+=( "LD=/usr/bin/ld" )
ARGS+=( "AR=/usr/bin/ar -rc" )
ARGS+=( "RANLIB=/usr/bin/ranlib" )
ARGS+=( "EPICS_BASE=${PREFIX}" )
ARGS+=( "INSTALL_LOCATION=${PREFIX}" )
ARGS+=( "INSTALL_LIB=${PREFIX}/lib" )
ARGS+=( "INSTALL_SHRLIB=${PREFIX}/lib" )
ARGS+=( "INSTALL_TCLLIB=${PREFIX}/lib" )
ARGS+=( "INSTALL_BIN=${PREFIX}/bin" )
ARGS+=( "SYSGSL=1")
```

## Prepare base build environment

EPICS base configuration
```
mkdir -p "${PREFIX}"
mkdir -p "${RPN_DEFNS%/*}"
cp "${DOWNLOAD_DIR}/defns.rpn" "${RPN_DEFNS}"
cd "${PREFIX}"
tar xvf "${DOWNLOAD_DIR}/epics.base.configure.tar.gz"
cd epics/base
make -e "${ARGS[@]}"
```

## Unpack EPICS extensions and OAG apps configuration

```
ARGS+=( "TOOLS=${PREFIX}/bin")
cd "${PREFIX}"
tar xvf "${DOWNLOAD_DIR}/epics.extensions.configure.tar.gz"
tar xvf "${DOWNLOAD_DIR}/oag.apps.configure.tar.gz"
cd "${PREFIX}/oag/apps/configure"
sed -i "s/clean::/clean:/" RULES_PYTHON
make -e "${ARGS[@]}"
```

>
You have to fix the `clean::` target in `${PREFIX}/oag/apps/configure/PYTHON_RULES`

## Build required tools and libraries from SDDS
```
cd "${PREFIX}"
tar xvf "${DOWNLOAD_DIR}/SDDS.${SDDS_VERSION}.tar.gz"
cd "${PREFIX}/epics/extensions/src/SDDS/"
make -e "${ARGS[@]}" -C fftpack   && \
make -e "${ARGS[@]}" -C lzma      && \
make -e "${ARGS[@]}" -C matlib    && \
make -e "${ARGS[@]}" -C mdbcommon && \
make -e "${ARGS[@]}" -C mdblib    && \
make -e "${ARGS[@]}" -C mdbmth    && \
make -e "${ARGS[@]}" -C meschach  && \
make -e "${ARGS[@]}" -C namelist  && \
make -e "${ARGS[@]}" -C pgapack   && \
make -e "${ARGS[@]}" -C rpns/code && \
make -e "${ARGS[@]}" -C SDDSlib   && \
make -e "${ARGS[@]}" -C SDDSlib clean
make    "${ARGS[@]}" MPI=1 -C SDDSlib
```

## Compile (P)elegant

```
cd "${PREFIX}"
tar xvf "${DOWNLOAD_DIR}/elegant.${ELEGANT_VERSION}.tar.gz"

PATH+=":${PREFIX}/bin"

cd "${PREFIX}/oag/apps/src/elegant"
make -e "${ARGS[@]}"
make clean
make    "${ARGS[@]}"  Pelegant
```
