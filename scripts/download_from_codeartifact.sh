#!/bin/bash
set -e

echo "=== Downloading artifacts from CodeArtifact ==="

# Configuration
DOMAIN="project2"
REPOSITORY="project2_carepo"
REGION="ap-south-1"
ACCOUNT_ID="975050380744"
PACKAGE_NAME="EcommWebApp"
PACKAGE_NAMESPACE="ecomm-app"

# Get the build version from environment variable or use latest
BUILD_VERSION=${CODEBUILD_BUILD_NUMBER:-"latest"}

if [ "$BUILD_VERSION" = "latest" ]; then
    echo "Finding latest version in CodeArtifact..."
    BUILD_VERSION=$(aws codeartifact list-package-versions \
        --domain $DOMAIN \
        --domain-owner $ACCOUNT_ID \
        --repository $REPOSITORY \
        --format generic \
        --namespace $PACKAGE_NAMESPACE \
        --package $PACKAGE_NAME \
        --region $REGION \
        --query 'sort_by(versions, &version)[-1].version' \
        --output text)
fi

echo "Downloading version: $BUILD_VERSION"

# Get CodeArtifact authorization token
echo "Getting CodeArtifact token..."
export CODEARTIFACT_AUTH_TOKEN=$(aws codeartifact get-authorization-token \
    --domain $DOMAIN \
    --domain-owner $ACCOUNT_ID \
    --region $REGION \
    --query authorizationToken \
    --output text)

# Extract build number from version
BUILD_NUMBER=${BUILD_VERSION#1.0.}

# Download deployment bundle from CodeArtifact
echo "Downloading deployment bundle..."
aws codeartifact get-package-version-asset \
    --domain $DOMAIN \
    --domain-owner $ACCOUNT_ID \
    --repository $REPOSITORY \
    --format generic \
    --namespace $PACKAGE_NAMESPACE \
    --package $PACKAGE_NAME \
    --package-version $BUILD_VERSION \
    --asset deployment-bundle-${BUILD_NUMBER}.zip \
    --region $REGION \
    deployment-bundle.zip

# Verify download
if [ $? -eq 0 ] && [ -f "deployment-bundle.zip" ]; then
    echo "Download successful! Extracting files..."
    
    # Extract the bundle
    unzip -o deployment-bundle.zip
    
    # Verify extracted files
    echo "Extracted files:"
    ls -la
    
    # Ensure scripts are executable
    chmod +x scripts/*.sh
    
    echo "=== CodeArtifact download completed successfully ==="
else
    echo "ERROR: Failed to download from CodeArtifact"
    exit 1
fi
