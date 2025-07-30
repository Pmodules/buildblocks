# Alphafold3

AlphaFold 3, introduced in May 2024 by Google DeepMind in collaboration with Isomorphic Labs, represents a significant advancement in computational biology. Building upon the success of AlphaFold 2, which revolutionized protein structure prediction, AlphaFold 3 extends its capabilities to accurately predict the 3D structures and interactions of a wide array of biomolecules, including proteins, DNA, RNA, ligands, and ions.

https://github.com/google-deepmind/alphafold3

## Installation
The Alphafold3 installation is performed using a Docker container or singularity image (https://github.com/google-deepmind/alphafold3/blob/main/docs/installation.md). Here, we decided to install Alphafold3 by first building a container image using Singularity and then a alphafold3 executable to run that image.

Here are the steps for the installation:

1. Download the Alphafold3 release from the github repository.
```bash
export VERSION=3.0.1
wget https://github.com/google-deepmind/alphafold3/archive/refs/tags/v${VERSION}.tar.gz

tar -xzf v${VERSION}.tar.gz
rm v${VERSION}.tar.gz
cd alphafold3-${VERSION}
```

2. Create a dicrectory named `certificates` in the same directory where you downloaded the Alphafold3 release, and copy the CA certificates PEM file into it. This is necessary to ensure that the container can access the required CA certificates for secure connections.
```bash
mkdir -p certificates
cp /var/lib/ca-certificates/ca-bundle.pem certificates/
```

3. In `docker/Dockerfile`, add `ca-certificates` to the apt install packages and and copy the PEM file into the container:
```bash
RUN apt update --quiet \
    && apt install --yes --quiet ca-certificates \
    && apt install --yes --quiet software-properties-common \
    && apt install --yes --quiet git wget gcc g++ make zlib1g-dev zstd

# Copy the PEM file into the container
COPY certificates/ca-bundle.pem /usr/local/share/ca-certificates/ca-bundle.crt

# Update the CA trust store
RUN update-ca-certificates

# Set certificate environmental variables
ENV REQUESTS_CA_BUNDLE=/usr/local/share/ca-certificates/ca-bundle.crt
ENV SSL_CERT_FILE=/usr/local/share/ca-certificates/ca-bundle.crt
```

4. Build the container image and convert it to a Singularity image file (SIF):
```bash
# Build the container image with Podman
podman build -t alphafold3:latest -f docker/Dockerfile .

# Save the image into OCI Archive format in a .tar file with Podman
podman save --format oci-archive -o alphafold3.tar localhost/alphafold3:latest

# Convert the .tar file into a .sif file with Singularity
singularity build alphafold3.sif oci-archive://alphafold3.tar

# Remove the .tar file
rm alphafold3.tar

# Move the .sif file to the parent directory
mv alphafold3.sif ..

# Move to the parent directory
cd ..

# Change the .sif file permissions
chmod 775 alphafold3.sif
```

5. Set the environamental variable APPTAINER_IMAGE to the directory where the .sif file is located.
Also set the variable PUBLIC_DATABASES_DIR to the directory of the public databases to allow users to have that option without having to download the databases.
`setenv APPTAINER_IMAGE /data/project/bio/shared/containers/alphafold3/3.0.1/alphafold3.sif`
`setenv PUBLIC_DATABASES_DIR /data/project/bio/shared/alphafold3/public_databases`

6. Build the module.
