# AF3x

Custom modification of AlphaFold 3 enabling explicit modeling of crosslinks.

Most crosslink-based modeling programs implicitly model crosslinks by adding distance restraints between crosslinked residues. This program explicitly models crosslinks by adding crosslinker molecules as ligands and setting bonds to the crosslinked residues. This allows for more realistic modeling of crosslinks, and sometimes gives good results. The results are also more visually appealing.

https://github.com/KosinskiLab/af3x

## Installation
The AF3x installation is performed using a Docker container or singularity image using the Dockefile from the AF3x repository https://github.com/KosinskiLab/af3x/blob/main/docker/Dockerfile.

Here are the steps for the singularity image:

1. Clone the AF3x repository from the github repository.
```bash
git clone https://github.com/KosinskiLab/af3x
cd af3x
```

2. Create a directory named `certificates` in the same directory where you cloned the AF3x repository, and copy the CA certificates PEM file into it. This is necessary to ensure that the container can access the required CA certificates for secure connections.
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
podman build -t af3x:latest -f docker/Dockerfile .

# Save the image into OCI Archive format in a .tar file with Podman
podman save --format oci-archive -o af3x.tar localhost/af3x:latest

# Convert the .tar file into a .sif file with Singularity
singularity build af3x.sif oci-archive://af3x.tar

# Remove the .tar file
rm af3x.tar

# Move the .sif file to the parent directory
mv af3x.sif ..

# Move to the parent directory
cd ..

# Change the .sif file permissions
chmod 775 af3x.sif
```

5. Set the environamental variable APPTAINER_IMAGE to the directory where the .sif file is located.
Also set the variable PUBLIC_DATABASES_DIR to the directory of the public databases to allow users to have that option without having to download the databases.
`setenv APPTAINER_IMAGE /data/project/bio/shared/containers/af3x/3.0.1/af3x.sif`
`setenv PUBLIC_DATABASES_DIR /data/project/bio/shared/alphafold3/public_databases`

6. Build the module.
