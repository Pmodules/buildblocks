# PEET

[Particle Estimateion for Electron Tomography](https://bio3d.colorado.edu/PEET/)

## Installation

PEET is shipped as a self-expanding installation script. Run `./build` to
install.
This module is usually used in combination with IMOD (etomo GUI). 

## Testing

- `calcFSC` should print the version number

## Build notes


Linking the binary is a bit of a pain. It requires gcc to be loaded to provide
relatively recent versions of libstdc++.so.6. I didn't fine what exact version
Matlab MCR expects, but 9.5.0 seemed to work. MCR is linked dynamically at
runtime through LD_LIBRARY_PATH. This is not set in the modulefile as expected,
but rather in wrapper scripts which source particle.cfg. Sed commands in
pbuild::install update this file so that it reads the loaded modules correctly. 
(Remark Nov. 2024: still true for version 1.17.0) 

## Versions

According to the website (INSTALL.TXT) the following Matlab is needed : 

-1.17.0 : 2022b  (Merlin7, automatically loads matlab)
