# RFdiffusion

RFdiffusion is an open source method for structure generation, with or without conditional information (a motif, target etc). It can perform a whole range of protein design challenges as outlined in the [RFdiffusion paper](https://www.nature.com/articles/s41586-023-06415-8).

https://github.com/RosettaCommons/RFdiffusion

## Installation
The RFdiffusion installation can be performed using a Docker container or singularity image (https://github.com/RosettaCommons/RFdiffusion/tree/main/docker). Here, we decided to install RFdiffusion by first building a container image using Singularity and then a RFdiffusion executable to run that image.

Here are the steps for the singularity image:

1. Clone the RFdiffusion github repository.
```bash
git clone https://github.com/RosettaCommons/RFdiffusion.git
cd RFdiffusion
```

2. Create a directory named `certificates` in the same directory where you downloaded the RFdiffusion release, and copy the CA certificates PEM file into it. This is necessary to ensure that the container can access the required CA certificates for secure connections.
```bash
mkdir -p certificates
cp /var/lib/ca-certificates/ca-bundle.pem certificates/
```

3. In `docker/Dockerfile`, copy the PEM file into the container and set the environmental variables by adding the following lines:
```bash
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
podman build -t rfdiffusion:latest -f docker/Dockerfile .

# Save the image into OCI Archive format in a .tar file with Podman
podman save --format oci-archive -o rfdiffusion.tar localhost/rfdiffusion:latest

# Convert the .tar file into a .sif file with Singularity
singularity build rfdiffusion.sif oci-archive://rfdiffusion.tar

# Remove the .tar file
rm rfdiffusion.tar

# Move the .sif file to the parent directory
mv rfdiffusion.sif ..

# Move to the parent directory
cd ..

# Change the .sif file permissions
chmod 775 rfdiffusion.sif
```

5. Set the environamental variable APPTAINER_IMAGE to the directory where the .sif file is located.
Also set the variable MODEL_DIRECTORY_PATH to the directory of the models to allow users to have that option without having to download the models.
`setenv APPTAINER_IMAGE /data/project/bio/shared/containers/rfdiffusion/1.1.0-dev/rfdiffusion.sif`
`setenv MODEL_DIRECTORY_PATH /data/project/bio/shared/rfdiffusion/models`

6. Build the module.
