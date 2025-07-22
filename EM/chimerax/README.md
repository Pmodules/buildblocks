# ChimeraX
UCSF ChimeraX (or simply ChimeraX) is the next-generation molecular
visualization program from the Resource for Biocomputing, Visualization, and
Informatics (RBVI), following UCSF Chimera.

https://www.cgl.ucsf.edu/chimerax/

## Installation
The ChimeraX installation can be performed with .rpm or .deb files. The other 
option is to build it from source which "can be challenging because it depends
on more than 50 third party libraries and packages."
Thus, it has been decided to install ChimeraX by first building a container
image and then use the chimerax executable from that image.

Here are the steps for the installation:

1. Download the .deb file from the link
https://www.rbvi.ucsf.edu/chimerax/download.html and copy it to the location
where container images are saved.

2. In that directory, create a Dockerfile similar to the example below:
```
FROM ubuntu:24.04

ARG DEB_FILE
COPY ${DEB_FILE} /tmp/

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y /tmp/${DEB_FILE} && \
    rm -f /tmp/${DEB_FILE}

ENTRYPOINT ["/usr/bin/chimerax"]
```

3. In the same directory, run the following commands and set the variable 
DEB_FILE with the filename.
```
DEB_FILE=ucsf-chimerax_1.10ubuntu24.04_amd64.deb

# Build the container image with Podman
podman build --build-arg DEB_FILE=$DEB_FILE -t chimerax:latest -f Dockerfile .

# Save the image into OCI Archive format in a .tar file with Podman
podman save --format oci-archive -o chimerax.tar localhost/chimerax:latest

# Convert the .tar file into a .sif file with Singularity
singularity build chimerax.sif oci-archive://chimerax.tar

# Remove the .tar file
rm chimerax.tar

# Change the .sif file permissions
chmod 775 chimerax.sif
```

4. Set the environamental variable APPTAINER_IMAGE in the modulefile to the path
where the singularity image is located, for example:
`setenv APPTAINER_IMAGE /data/project/bio/shared/containers/chimerax/1.10/chimerax.sif`

5. Build the module. 
