# Rootless Podman Setup with GitHub Actions and SELinux

This project provides an Ansible solution to set up rootless Podman, configure SELinux, and deploy a GitHub Actions self-hosted runner for Linux environments. It is designed to be a validated pattern, starting with a simple playbook and evolving into roles and collections over time.

## Table of Contents
- [Introduction](#introduction)
- [Requirements](#requirements)
- [Installation](#installation)
- [Roles](#roles)
- [Usage](#usage)
- [Next Steps](#next-steps)
- [Contributing](#contributing)
- [License](#license)

## Introduction

This project is structured into roles that handle:
1. Installing and configuring Podman and Podman-docker for rootless usage.
2. Configuring SELinux to allow secure container management.
3. Installing and setting up a GitHub Actions self-hosted runner.
4. Enabling rootless Podman with the necessary user permissions.

The initial playbook has been broken down into roles, making it modular and easy to adapt or extend. 

## Requirements

To use this playbook, you need:
- Ansible 2.9 or later installed on the control node.
- SSH access to the target machine where rootless Podman and GitHub Actions will be deployed.
- Sudo privileges on the target machine.

### Supported Platforms
- Red Hat Enterprise Linux 8.x (or compatible)

## Installation

1. Clone this repository:
    ```bash
    git clone https://github.com/yourrepo/rootless-podman-setup.git
    cd rootless-podman-setup
    ```

2. Ensure you have Ansible installed on your control node. If not, install it:
    ```bash
    sudo yum install ansible
    ```

3. Set up the inventory file with your target machine information. Modify the `hosts` file or create your own to reflect the target hosts:
    ```ini
    [all]
    target_host ansible_host=192.168.x.x ansible_user=user
    ```

## Roles

### 1. `podman`
This role installs Podman and Podman-docker. It ensures that Podman is available to manage containers and provides compatibility with Docker CLI commands.

### 2. `selinux`
The SELinux role installs the necessary SELinux packages and configures policies for container management and the GitHub Actions runner.

### 3. `github_runner`
This role handles the installation and configuration of a GitHub Actions self-hosted runner on the target machine. The runner will be downloaded, extracted, and installed, then configured to run as a service.

### 4. `rootless_config`
The rootless configuration role enables rootless Podman by setting the necessary permissions for the user to run containers without root privileges.

## Usage

To run the playbook, execute the following command:

```bash
ansible-playbook -i hosts site.yml
