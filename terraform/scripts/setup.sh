#!/bin/bash

# This script sets up the necessary environment for deploying multi-cloud Kubernetes clusters using Terraform.

# Update package lists
echo "Updating package lists..."
sudo apt-get update -y

# Install necessary tools
echo "Installing Terraform..."
sudo apt-get install -y unzip
wget https://releases.hashicorp.com/terraform/$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r .current_version)/terraform_$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r .current_version)_linux_amd64.zip
unzip terraform_$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r .current_version)_linux_amd64.zip
sudo mv terraform /usr/local/bin/
rm terraform_$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r .current_version)_linux_amd64.zip

echo "Installing Azure CLI..."
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

echo "Installing AWS CLI..."
sudo apt-get install -y awscli

echo "Installing Google Cloud SDK..."
echo "Adding Google Cloud SDK distribution URI as a package source..."
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
echo "Importing the Google Cloud public key..."
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
sudo apt-get update -y
sudo apt-get install -y google-cloud-sdk

# Verify installations
echo "Verifying installations..."
terraform version
az --version
aws --version
gcloud --version

echo "Setup completed successfully!"