#!/bin/bash

# Docker image build script for GitOps Demo App

# Configuration
REGISTRY="ghcr.io"
USERNAME="nguyendang52"
IMAGE_NAME="gitops-demo-app"

# Get the first 8 characters of the current commit hash
COMMIT_HASH=$(git rev-parse --short=8 HEAD)

# Check if we're in a git repository
if [ -z "$COMMIT_HASH" ]; then
    echo -e "${RED}Error: Not in a git repository or no commits found${NC}"
    exit 1
fi

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}Building Docker Image${NC}"
echo -e "${BLUE}================================${NC}"

# Build with commit hash tag
IMAGE_TAG="${REGISTRY}/${USERNAME}/${IMAGE_NAME}:${COMMIT_HASH}"
IMAGE_LATEST="${REGISTRY}/${USERNAME}/${IMAGE_NAME}:latest"

echo -e "${BLUE}Commit Hash:${NC} ${COMMIT_HASH}"
echo -e "${BLUE}Image Tag:${NC} ${IMAGE_TAG}"
echo -e "${BLUE}Latest Tag:${NC} ${IMAGE_LATEST}"
echo ""

# Build the Docker image
echo -e "${BLUE}Building image...${NC}"
docker build -t "${IMAGE_TAG}" -t "${IMAGE_LATEST}" .

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Build successful!${NC}"
    echo ""
    echo -e "${GREEN}Built images:${NC}"
    echo -e "  - ${IMAGE_TAG}"
    echo -e "  - ${IMAGE_LATEST}"
    echo ""
    echo -e "${BLUE}To run the container:${NC}"
    echo -e "  docker run -p 3000:3000 ${IMAGE_LATEST}"
    echo ""
    echo -e "${BLUE}To push to registry (if configured):${NC}"
    echo -e "  docker push ${IMAGE_TAG}"
    echo -e "  docker push ${IMAGE_LATEST}"
else
    echo -e "${RED}✗ Build failed!${NC}"
    exit 1
fi
