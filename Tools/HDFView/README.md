# Build HDFView module

## Notations

`$P`: Package name here HDFView
`$V`: Package version

## Download

Download the package from https://www.hdfgroup.org/downloads/hdfview/. The compressed tar-file contains a shell-script installer.

## Install

1. Unpack the downloaded tar-file
1. HDFView is installed in the group 'Tools'
2. change to the directory `/opt/psi/Tools'
3. Run the installer script
4. Accept the license
5. Answer 'no' to the question "Do you want to include the subdirectory HDFView-$V-Linux?"
6. HDFView will be installed with the relative path `HDFView/$V`
7. 