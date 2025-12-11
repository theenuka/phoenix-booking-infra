#!/bin/bash
# Setup Terraform backend (S3 + DynamoDB)
# Run this ONCE before terraform init

set -e

BUCKET_NAME="phoenix-booking-terraform-state"
DYNAMODB_TABLE="phoenix-booking-terraform-lock"
REGION="us-east-1"

echo "=================================================="
echo "Setting up Terraform Backend Infrastructure"
echo "=================================================="

# Create S3 bucket for state storage
echo "Creating S3 bucket: $BUCKET_NAME"
aws s3api create-bucket \
    --bucket "$BUCKET_NAME" \
    --region "$REGION" 2>/dev/null || echo "Bucket already exists"

# Enable versioning on the bucket
echo "Enabling versioning on S3 bucket..."
aws s3api put-bucket-versioning \
    --bucket "$BUCKET_NAME" \
    --versioning-configuration Status=Enabled \
    --region "$REGION"

# Enable encryption on the bucket
echo "Enabling encryption on S3 bucket..."
aws s3api put-bucket-encryption \
    --bucket "$BUCKET_NAME" \
    --server-side-encryption-configuration '{
        "Rules": [{
            "ApplyServerSideEncryptionByDefault": {
                "SSEAlgorithm": "AES256"
            }
        }]
    }' \
    --region "$REGION"

# Block public access
echo "Blocking public access to S3 bucket..."
aws s3api put-public-access-block \
    --bucket "$BUCKET_NAME" \
    --public-access-block-configuration \
        "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true" \
    --region "$REGION"

# Create DynamoDB table for state locking
echo "Creating DynamoDB table: $DYNAMODB_TABLE"
aws dynamodb create-table \
    --table-name "$DYNAMODB_TABLE" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --region "$REGION" \
    --tags Key=Project,Value=PhoenixBooking Key=ManagedBy,Value=Terraform 2>/dev/null || echo "Table already exists"

# Wait for table to be active
echo "Waiting for DynamoDB table to be active..."
aws dynamodb wait table-exists --table-name "$DYNAMODB_TABLE" --region "$REGION"

echo ""
echo "=================================================="
echo "✅ Terraform backend setup complete!"
echo "=================================================="
echo ""
echo "S3 Bucket: $BUCKET_NAME"
echo "DynamoDB Table: $DYNAMODB_TABLE"
echo "Region: $REGION"
echo ""
echo "You can now run:"
echo "  cd terraform"
echo "  terraform init"
echo "=================================================="
