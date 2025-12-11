#!/bin/bash

set -e  # Exit on error

# Variables
CLUSTER_NAME="phoenix-cluster"
REGION="us-east-1"

# Get VPC ID dynamically from Terraform
echo "Fetching VPC ID from Terraform..."
VPC_ID=$(cd ../terraform && terraform output -raw vpc_id 2>/dev/null || echo "")

if [ -z "$VPC_ID" ]; then
    echo "❌ Error: Could not fetch VPC ID from Terraform"
    echo "Please ensure Terraform is initialized and applied in ../terraform directory"
    echo "Or set VPC_ID manually: export VPC_ID=vpc-xxxxx"
    exit 1
fi

echo "✅ Using VPC ID: $VPC_ID"

# 1. Install Helm if not installed
if ! command -v helm &> /dev/null; then
    echo "Helm not found. Installing..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

# 2. Add Helm Repos
helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver
helm repo add eks https://aws.github.io/eks-charts
helm repo update

# 3. Install AWS EBS CSI Driver
echo "Installing AWS EBS CSI Driver..."
helm upgrade --install aws-ebs-csi-driver aws-ebs-csi-driver/aws-ebs-csi-driver \
  --namespace kube-system \
  --set controller.extraVolumeTags.Name=phoenix-ebs-volume

# 4. Install AWS Load Balancer Controller
echo "Installing AWS Load Balancer Controller..."
helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  --namespace kube-system \
  --set clusterName=$CLUSTER_NAME \
  --set serviceAccount.create=true \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=$REGION \
  --set vpcId=$VPC_ID

echo "Installation complete!"
