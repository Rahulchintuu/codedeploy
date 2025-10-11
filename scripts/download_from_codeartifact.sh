#!/bin/bash
set -e

echo "=== Downloading from CodeArtifact ==="

DOMAIN="project2"
REPOSITORY="project2_carepo"
REGION="ap-south-1"
ACCOUNT_ID="975050380744"

# Get latest version
VERSION=$(aws codeartifact list-package-versions \
    --domain $DOMAIN \
    --domain-owner $ACCOUNT_ID \
    --repository $REPOSITORY \
    --format generic \
    --namespace ecomm-app \
    --package EcommWebApp \
    --region $REGION \
    --query 'sort_by(versions, &version)[-1].version' \
    --output text)

echo "Downloading version: $VERSION"

# Get authorization token
export CODEARTIFACT_AUTH_TOKEN=$(aws codeartifact get-authorization-token \
    --domain $DOMAIN \
    --domain-owner $ACCOUNT_ID \
    --region $REGION \
    --query authorizationToken \
    --output text)

BUILD_NUMBER=${VERSION#1.0.}

# Download deployment bundle
echo "Downloading bundle-${BUILD_NUMBER}.zip..."
aws codeartifact get-package-version-asset \
    --domain $DOMAIN \
    --domain-owner $ACCOUNT_ID \
    --repository $REPOSITORY \
    --format generic \
    --namespace ecomm-app \
    --package EcommWebApp \
    --package-version $VERSION \
    --asset bundle-${BUILD_NUMBER}.zip \
    --region $REGION \
    deployment-bundle.zip

# Extract files
echo "Extracting files..."
unzip -o deployment-bundle.zip

# Make all scripts executable
chmod +x scripts/*.sh

echo "=== Download completed ==="
