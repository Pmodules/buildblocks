# FLUKA and Flair module

PSI has a institutional license for FLUKA and Flair. Anyway users should register.

## Download

https://fluka.cern

https://flair.web.cern.ch/flair/index.html

https://fluka.cern/download/neutron-data-libraries

You have to register before you can download FLUKA!

## Install
```
FLUKA4_VERSION=3.1
FLAIR_VERSION=3.2-2
GEOVIEWER_VERSION=3.2

GCC_VERSION=9.5.0
PYTHON_VERSION=3.9.10
TCLTK_VERSION=8.6.9

PREFIX="${PMODULES_ROOT}/Compiler/fluka4/${FLUKA4_VERSION}/gcc/${GCC_VERSION}"
DISTFILES_DIR='/afs/psi.ch/software/Pmodules/distfiles'
FLUKA_TAR="${DISTFILES_DIR}/fluka-4-${FLUKA4_VERSION}.x86-Linux-gfor${GCC_VERSION/.*}.tgz"
FLAIR_TAR="${DISTFILES_DIR}/flair-${FLAIR_VERSION}.tgz"
GEOVIEWER_TAR="${DISTFILES_DIR}/flair-geoviewer-${GEOVIEWER_VERSION}.tgz"

module load gcc/${GCC_VERSION} Python/${PYTHON_VERSION} TclTk/${TCLTK_VERSION}

mkdir -p "${PREFIX}" && cd "$_"

tar --strip-components=1 -xvf "${FLUKA_TAR}"
cd src
make

mkdir -p "${PREFIX}/flair" && cd "$_"
tar --strip-components=1 -xvf "${FLAIR_TAR}"
make

# geoviewer: to be tested
tar --strip-components=1 --directory=geoviewer -xvf "${GEOVIEWER_TAR}"
cd geoviewer
make
make DESTDIR="${PREFIX}/flair" install

cd "${PREFIX}"
ln -s lib lib64
cp -av "${TCLTK_DIR}/lib/libtcl8.6.so" lib
cp -av "${TCLTK_DIR}/lib/libtk8.6.so"  lib64

echo "gcc/${GCC_VERSION}"       > .dependencies
echo "Python/${PYTHON_VERSION}" >> .dependencies
```
