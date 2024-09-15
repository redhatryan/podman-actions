To package this solution for a customer that uses RHEL but does not use OpenShift, you can create a script that automates the provisioning of a GitHub Actions self-hosted runner on a RHEL host. This script will handle the installation of necessary dependencies, configuration of the GitHub runner, and ensure it runs as a service.

Here’s a step-by-step guide to achieve this:

Step 1: Prerequisites
Ensure the customer has:

A RHEL host with internet access.
GitHub Personal Access Token (PAT) with the necessary scopes.
Access to a GitHub repository where the runner will be registered.
Step 2: Create the Provisioning Script
Create a script that performs the following tasks:

Installs necessary dependencies (Podman, SELinux utilities).
Registers the GitHub Actions runner using a provided token.
Configures the runner to run as a service.
provision-github-runner.sh:

bash
Copy code
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
Step 3: Create a Systemd Service for the GitHub Runner
Ensure the GitHub Actions runner is configured to run as a service. This is handled within the script using the svc.sh install and svc.sh start commands.

Step 4: Package the Solution
You can package the script and any necessary configuration files into a tarball or distribute them as a GitHub repository for easy access and version control.

Packaging Example:

bash
Copy code
tar czvf github-actions-runner-setup.tar.gz provision-github-runner.sh
Step 5: Provide Usage Instructions
Include usage instructions for the customer to follow:

README.md:

markdown
Copy code
# GitHub Actions Runner Provisioning Script for RHEL

This script automates the provisioning of a GitHub Actions self-hosted runner on a RHEL host.

## Prerequisites

- A RHEL host with internet access.
- GitHub Personal Access Token (PAT) with `repo` and `admin:repo` scopes.
- Access to a GitHub repository where the runner will be registered.

## Usage

1. Download the provisioning script:

   ```sh
   curl -O https://your-server.com/path/to/provision-github-runner.sh
Make the script executable:

sh
Copy code
chmod +x provision-github-runner.sh
Run the script and follow the prompts:

sh
Copy code
./provision-github-runner.sh
The script will install necessary dependencies, configure the GitHub Actions runner, and start it as a service.

Notes
Ensure SELinux is enabled and enforcing on your RHEL host.
The runner service will start automatically and be ready to use with your GitHub repository.
css
Copy code

### Summary

This solution involves a simple script that automates the setup of a GitHub Actions self-hosted runner on a RHEL host. It installs necessary dependencies, configures the runner using a provided token, and ensures it runs as a service. This approach provides a straightforward method for customers who do not use OpenShift but need to set up GitHub Actions runners on RHEL.

By packaging the script and providing clear usage instructions, customers can easily provision and manage GitHub Actions self-hosted runners on their RHEL hosts, leveraging the power of automation and parallelism in their CI/CD workflows.