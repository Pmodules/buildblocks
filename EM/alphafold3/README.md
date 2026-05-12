# Alphafold3

AlphaFold 3, introduced in May 2024 by Google DeepMind in collaboration with Isomorphic Labs, represents a significant advancement in computational biology. Building upon the success of AlphaFold 2, which revolutionized protein structure prediction, AlphaFold 3 extends its capabilities to accurately predict the 3D structures and interactions of a wide array of biomolecules, including proteins, DNA, RNA, ligands, and ions.

https://github.com/google-deepmind/alphafold3

## Installation
The Alphafold3 installation is performed using a Docker container or singularity image (https://github.com/google-deepmind/alphafold3/blob/main/docs/installation.md). Here, we decided to install Alphafold3 by first building a container image using Singularity and then a alphafold3 executable to run that image.

Here are the steps for the singularity image:

1. Download the Alphafold3 release from the github repository.
```bash
export VERSION=3.0.2
wget https://github.com/google-deepmind/alphafold3/archive/refs/tags/v${VERSION}.tar.gz

tar -xzf v${VERSION}.tar.gz
rm v${VERSION}.tar.gz
cd alphafold3-${VERSION}
```

2. Create a directory named `certificates` in the same directory where you downloaded the Alphafold3 release, and copy the CA certificates PEM file into it. This is necessary to ensure that the container can access the required CA certificates for secure connections.
```bash
mkdir -p certificates
cp /var/lib/ca-certificates/ca-bundle.pem certificates/
```

3. In `docker/Dockerfile`, add `ca-certificates` to the apt install packages and and copy the PEM file into the container:
```bash
RUN DEBIAN_FRONTEND=noninteractive \
apt-get update --quiet \
&& apt install --yes --quiet ca-certificates

# Copy the PEM file into the container
COPY certificates/ca-bundle.pem /usr/local/share/ca-certificates/ca-bundle.crt

# Update the CA trust store
RUN update-ca-certificates

# Set certificate environmental variables
ENV REQUESTS_CA_BUNDLE=/usr/local/share/ca-certificates/ca-bundle.crt
ENV SSL_CERT_FILE=/usr/local/share/ca-certificates/ca-bundle.crt

RUN DEBIAN_FRONTEND=noninteractive \
apt-get update --quiet \
&& apt-get install --yes --quiet python3.12 python3.12-dev \
&& apt-get install --yes --quiet git wget gcc g++ make zlib1g-dev zstd
```

4. Set the environmental variable `UV_CONCURRENCY=1` and `UV_COMPILE_BYTECODE=0`. Also change the UV_LINK_MODE from `copy` to `hardlink`.
```dockerfile
ENV UV_CONCURRENCY=1
ENV UV_COMPILE_BYTECODE=0

RUN --mount=type=cache,target=/root/.cache/uv \
    UV_LINK_MODE=hardlink uv sync --frozen --all-groups --no-editable
```

5. Build the container image and convert it to a Singularity image file (SIF):
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
