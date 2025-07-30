#!/bin/bash

# Compliance Dashboard - Build and Deploy Script for OpenShift
# This script builds the Docker image and deploys to OpenShift

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
IMAGE_NAME="compliance-dashboard"
IMAGE_TAG="latest"
NAMESPACE="compliance-dashboard"
PROJECT_NAME="compliance-dashboard"

echo -e "${GREEN}🚀 Starting Compliance Dashboard deployment to OpenShift...${NC}"

# Check if oc CLI is available
if ! command -v oc &> /dev/null; then
    echo -e "${RED}❌ OpenShift CLI (oc) not found. Please install it first.${NC}"
    exit 1
fi

# Check if logged into OpenShift
if ! oc whoami &> /dev/null; then
    echo -e "${RED}❌ Not logged into OpenShift. Please run 'oc login' first.${NC}"
    exit 1
fi

echo -e "${YELLOW}📋 Current OpenShift user: $(oc whoami)${NC}"
echo -e "${YELLOW}📍 Current OpenShift cluster: $(oc cluster-info | head -1)${NC}"

# Create or switch to project
echo -e "${GREEN}📁 Creating/switching to project: ${PROJECT_NAME}${NC}"
oc new-project ${PROJECT_NAME} 2>/dev/null || oc project ${PROJECT_NAME}

# Build the image using OpenShift BuildConfig
echo -e "${GREEN}🔨 Building Docker image...${NC}"

# Create BuildConfig if it doesn't exist
if ! oc get bc/${PROJECT_NAME} &> /dev/null; then
    echo -e "${YELLOW}📦 Creating BuildConfig...${NC}"
    oc new-build --binary --name=${PROJECT_NAME} --image-stream=nginx:alpine --to=${IMAGE_NAME}:${IMAGE_TAG}
fi

# Start build from current directory
echo -e "${GREEN}🏗️ Starting build...${NC}"
oc start-build ${PROJECT_NAME} --from-dir=. --follow --wait

# Deploy using kustomize
echo -e "${GREEN}📦 Deploying to OpenShift using kustomize...${NC}"
oc apply -k openshift/

# Wait for deployment to be ready
echo -e "${GREEN}⏳ Waiting for deployment to be ready...${NC}"
oc rollout status deployment/compliance-dashboard -n ${NAMESPACE} --timeout=300s

# Get the route URL
echo -e "${GREEN}🌐 Getting route URL...${NC}"
ROUTE_URL=$(oc get route compliance-dashboard-route -n ${NAMESPACE} -o jsonpath='{.spec.host}' 2>/dev/null || echo "")

if [ -n "$ROUTE_URL" ]; then
    echo -e "${GREEN}✅ Deployment successful!${NC}"
    echo -e "${GREEN}🌍 Dashboard URL: https://${ROUTE_URL}${NC}"
    echo -e "${YELLOW}📱 You can now access the Compliance Dashboard from the internet!${NC}"
else
    echo -e "${YELLOW}⚠️ Deployment completed but route URL not found. Check route manually:${NC}"
    echo -e "${YELLOW}   oc get route -n ${NAMESPACE}${NC}"
fi

echo -e "${GREEN}🎉 Deployment complete!${NC}"

# Show useful commands
echo -e "${YELLOW}"
echo "📚 Useful commands:"
echo "  View pods:           oc get pods -n ${NAMESPACE}"
echo "  View logs:           oc logs -f deployment/compliance-dashboard -n ${NAMESPACE}"
echo "  View route:          oc get route -n ${NAMESPACE}"
echo "  Scale deployment:    oc scale deployment/compliance-dashboard --replicas=3 -n ${NAMESPACE}"
echo "  Delete deployment:   oc delete -k openshift/"
echo -e "${NC}" 