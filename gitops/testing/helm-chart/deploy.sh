#!/bin/bash

# Function to prompt the user for input
prompt_for_input() {
  read -p "$1: " input
  echo $input
}

# Prompt the user for required fields
namespace=$(prompt_for_input "Enter the namespace")
storage_class=$(prompt_for_input "Enter the storage class")
github_runner_token=$(prompt_for_input "Enter the GitHub Runner token")

# Set environment variables for Helm values
export NAMESPACE=$namespace
export STORAGE_CLASS=$storage_class
export GITHUB_RUNNER_TOKEN=$github_runner_token

# Create a temporary directory for Helm values
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# Generate Helm values file
cat <<EOF > $tmpdir/values.yaml
namespace: $NAMESPACE
storageClassName: $STORAGE_CLASS
vm:
  githubRunnerToken: $GITHUB_RUNNER_TOKEN
EOF

# Deploy using Helm and Kustomize
helm upgrade --install rhel-vm helm-chart -f $tmpdir/values.yaml
kubectl apply -k deployments/overlays/production
