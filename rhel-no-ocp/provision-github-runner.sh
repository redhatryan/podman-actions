#!/bin/bash

# Function to prompt for input
prompt_for_input() {
  read -p "$1: " input
  echo $input
}

# Prompt for necessary information
GITHUB_URL=$(prompt_for_input "Enter the GitHub repository URL (e.g., https://github.com/your-org/your-repo):")
GITHUB_TOKEN=$(prompt_for_input "Enter the GitHub Runner Registration Token:")
RUNNER_NAME=$(prompt_for_input "Enter the name for the GitHub Runner:")
RUNNER_WORK_DIRECTORY=$(prompt_for_input "Enter the work directory for the GitHub Runner (default: _work):")

# Set default work directory if not provided
RUNNER_WORK_DIRECTORY=${RUNNER_WORK_DIRECTORY:-_work}

# Update system and install dependencies
sudo yum update -y
sudo yum install -y podman policycoreutils-python-utils curl jq

# Ensure SELinux is enforcing
sudo setenforce 1

# Create runner user
sudo useradd -m -s /bin/bash runner
echo 'runner ALL=(ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/runner

# Switch to runner user
sudo -i -u runner bash << EOF

# Download and install GitHub Actions runner
cd ~
mkdir actions-runner && cd actions-runner
curl -o actions-runner-linux-x64-2.283.3.tar.gz -L https://github.com/actions/runner/releases/download/v2.283.3/actions-runner-linux-x64-2.283.3.tar.gz
tar xzf actions-runner-linux-x64-2.283.3.tar.gz

# Install dependencies
./bin/installdependencies.sh

# Configure the runner
./config.sh --url $GITHUB_URL --token $GITHUB_TOKEN --name $RUNNER_NAME --work $RUNNER_WORK_DIRECTORY --labels self-hosted

# Install runner as a service
sudo ./svc.sh install

# Start the runner service
sudo ./svc.sh start

EOF

echo "GitHub Actions runner has been successfully installed and started as a service."
