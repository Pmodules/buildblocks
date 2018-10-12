# The Mellanox MXM communication library

## Overview 

The Mellanox MXM communication library provides support for the Mellanox MXM interface for InfiniBand.

## Installation

For the module we use a RPM distributed by HP.

1. Create new directory `/opt/psi/System/mxm/VERSION_merlin`
1. Download RPM from https://downloads.linux.hpe.com/sdr/repo/mlnx_ofed/RedHatEnterpriseServer/
1. Unpack RPM with `rpm2cpio RPM | cpio -i --make-dirs` somewhere
1. copy all files from `opt/mellanox/mxm` to the module directory
1. adapt directories in `lib/pkg-config/mxm.pc`
1. add new variant to `files/variants`
1. run the build-script to install the modulefile and to set the release
 

> The shared library `libmxm.so`provided by the RPMs for RHEL 6 cannot be used to compile other software.
They requiry GLIBC >= 2.14, but on RHEL 6 only 2.12 is installed!