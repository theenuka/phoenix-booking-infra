#!/bin/bash
set -e

# Install AWS CLI if missing
if ! command -v aws &> /dev/null; then
    echo "Installing AWS CLI..."
    sudo apt-get update && sudo apt-get install -y awscli
fi

# Get all nodes
nodes=$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}')

for node in $nodes; do
    echo "Processing node: $node"
    
    # Construct private DNS name
    dns_name="${node}.ec2.internal"
    
    # Get Instance ID and AZ
    # We assume us-east-1 region as per variables.tf
    instance_info=$(aws ec2 describe-instances --region us-east-1 --filters "Name=private-dns-name,Values=$dns_name" --query "Reservations[0].Instances[0].[InstanceId,Placement.AvailabilityZone]" --output text)
    
    instance_id=$(echo $instance_info | awk '{print $1}')
    az=$(echo $instance_info | awk '{print $2}')
    
    if [ -z "$instance_id" ] || [ "$instance_id" == "None" ]; then
        echo "Error: Could not find instance for node $node"
        continue
    fi
    
    provider_id="aws:///$az/$instance_id"
    echo "Patching node $node with providerID: $provider_id"
    
    kubectl patch node $node -p "{\"spec\":{\"providerID\":\"$provider_id\"}}"
done

echo "All nodes patched!"