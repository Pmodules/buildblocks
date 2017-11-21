# Build HDFView module

## Notations

See https://gitlab.psi.ch/Pmodules/documentation/wikis/Development/Notations

`$PMODULES_ROOT`: root of Pmodules environment. At PSI this is `/opt/psi`.

`$GRP`: group the module is installed in, here 'Tools'

`$P`: package name, here HDFView.

`$V`: package version.

`$PREFIX`: prefix of module, this is `$PMODULES_ROOT/$GRP/$P/$V` which is at PSI `/opt/psi/Tools/HDFView/$V`.

`$BUILDBLOCK_DIR`: the directory of this file.

`MODULEFILES_DIR`: top-level directory where the modulefiles are installed relative to the group: `$PMODULES_ROOT/$GRP/modulefiles`.

`$RELEASE`: release of module, the value is either '`unstable`', '`stable`'   or '`deprecated`'

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