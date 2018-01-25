# Build HDFView module

## Notations

Please read [this document](https://gitlab.psi.ch/Pmodules/documentation/wikis/Development/Notations) for commonly used notations and environment variables.

## Setup environment

Set
1. `GRP='Tools'`
2. `P=HDFView`
3. `V` to the HDFView version to install
4. `PREFIX=$PMODULES_ROOT/$GRP/$P/$V`
5. `BUILDBLOCK_DIR` to the directory of this file.
6. `MODULEFILES_DIR=$PMODULES_ROOT/$GRP/modulefiles`.
7. `RELEASE` to the release of the module 

## Download

Download the package from https://www.hdfgroup.org/downloads/hdfview/. The compressed tar-file contains a shell-script installer.

## Install the package

1. Unpack the downloaded tar-file
2. `cd "$PMODULES_ROOT/Tools"`.
3. Run the installer script
4. Accept the license
5. Answer 'no' to the question "Do you want to include the subdirectory HDFView-$V-Linux?"
6. HDFView will be installed into `$PREFIX`

## Post-install

1. `mkdir "$PREFIX"/{bin,libexec}`
1. `mv "$PREFIX/hdfview.sh" "$PREFIX/libexec"`
2. `install --mode 0755 "$BUILDBLOCK_DIR/HDFView" "$PREFIX/bin"` 

## Install files for Pmodules

1. `install --mode 0644 "$BUILDBLOCK_DIR/modulefile" "$MODULEFILES_DIR/$P/$V"`
2. `echo "$RELEASE" > "$MODULEFILES_DIR/$P/.release-$V"`