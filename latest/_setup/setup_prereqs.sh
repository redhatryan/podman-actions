#!/bin/bash

# Script to install prerequisites for running the Ansible playbook on the local host

# Function to check if a package is installed
check_install_package() {
    PACKAGE=$1
    if ! dpkg -s $PACKAGE >/dev/null 2>&1; then
        echo "$PACKAGE is not installed. Installing..."
        sudo apt-get install -y $PACKAGE
    else
        echo "$PACKAGE is already installed."
    fi
}

# Function to install Ansible
install_ansible() {
    if ! command -v ansible >/dev/null 2>&1; then
        echo "Ansible is not installed. Installing Ansible..."
        sudo apt-get update
        sudo apt-get install -y ansible
    else
        echo "Ansible is already installed."
    fi
}

# Function to install Git on the local host
install_git() {
    if ! command -v git >/dev/null 2>&1; then
        echo "Git is not installed. Installing Git..."
        sudo apt-get install -y git
    else
        echo "Git is already installed."
    fi
}

# Step 1: Update the system packages
echo "Updating system packages..."
sudo apt-get update

# Step 2: Install Ansible on the local host
echo "Installing Ansible on local host..."
install_ansible

# Step 3: Install Git on the local host (if needed)
echo "Installing Git on local host..."
install_git

# Step 4: Ensure Python3 and pip3 are installed
echo "Installing Python3 and pip3 on local host..."
check_install_package python3
check_install_package python3-pip

# Step 5: Upgrade pip3
echo "Upgrading pip3..."
sudo pip3 install --upgrade pip

echo "All prerequisites have been installed on the local host. You can now run the Ansible playbook."
