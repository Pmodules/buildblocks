# How To Install GAMS

## Download the proper GAMS version

Download the proper GAMS version from https://www.gams.com/latest/ (notice that older versions are found in the `Previous Distributions` box).
Notice that the **GNU/Linux Systems** version is required for HPC systems.

## Manual installation of GAMS

GAMS is shipped through an executable file, which will expand all files into a single directory.

1. Create a directory for the new version. Example for version 42.3.0:
```bash
mkdir -p /opt/psi/Tools/GAMS/42.3.0
```
2. Copy the executable to the new created directory
```bash
mv linux_x64_64_sfx.exe /opt/psi/Tools/GAMS/42.3.0/
```
3. Change permissions of the executable accordingly
```bash
chmod +x /opt/psi/Tools/GAMS/42.3.0/linux_x64_64_sfx.exe
```
4. Execute it to install the software
```bash
cd /opt/psi/Tools/GAMS/42.3.0
./linux_x64_64_sfx.exe
```
5. The created subdirectory is created with the pattern: `gams${v_MAJOR}.${V_MINOR}_linux_x64_64_sfx`. Examples:
```bash
/opt/psi/Tools/GAMS/31.1.1/gams31.1_linux_x64_64_sfx
/opt/psi/Tools/GAMS/42.3.0/gams42.3_linux_x64_64_sfx
```
6. Add the proper version in the variants file and run the build file
```bash
cd ~/buildblocks/Tools/GAMS
echo "GAMS/42.3.0   unstable" >> files/variants.rhel7
./build 42.3.0
```

