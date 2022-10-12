# PEET

[Particle Estimateion for Electron Tomography](https://bio3d.colorado.edu/PEET/)

## Installation

PEET is shipped as a self-expanding installation script. Run `./build` to
install.

An experimental config.yaml files is included using Pmodules/1.1.10 syntax.
This should probably not be used until yaml support in modbuild stabilizes.

## Testing

- `calcFSC` should print the version number

## Build notes

Building was successful with Pmodules 1.1.8 but not 1.1.9 or 1.1.10.

Linking the binary is a bit of a pain. It requires gcc to be loaded to provide
relatively recent versions of libstdc++.so.6. I didn't fine what exact version
Matlab MCR expects, but 9.5.0 seemed to work. MCR is linked dynamically at
runtime through LD_LIBRARY_PATH. This is not set in the modulefile as expected,
but rather in wrapper scripts which source particle.cfg. Sed commands in
pbuild::install update this file so that it reads the loaded modules correctly.

