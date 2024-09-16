# Rootless Podman Setup with GitHub Actions and SELinux

This guide provides steps to install the necessary prerequisites and run an Ansible playbook that sets up rootless Podman, GitHub Actions self-hosted runner, and configures SELinux on the target machine.

## Prerequisites

Before running the playbook, you need to ensure that both the control node (your local machine) and the target machine meet the following requirements:

1. **Ansible** must be installed on the control node.
2. **SSH access** should be configured between the control node and the target machine.
3. **Python3 and pip3** must be installed on the target machine.
4. The user on the target machine must have **sudo privileges**.
5. **Git** must be installed on the target machine (for GitHub Actions setup).

## Automated Prerequisites Installation

To make the setup easier, a script is provided to automatically install these prerequisites on both the control node and the target machine.

### Steps to Run the Prerequisites Setup Script

1. Clone the repository or download the playbook file.

   ```bash
   git clone https://github.com/redhatryan/podman-actions.git
   cd podman/actions/latest/_setup
   ```
