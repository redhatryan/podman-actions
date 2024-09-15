# Rootless Podman Setup with GitHub Actions and SELinux

This Ansible playbook automates the setup of a rootless Podman environment, configured to work with a GitHub Actions self-hosted runner and secured with SELinux.

## Requirements

- **Ansible** must be installed on your control node.
- **Target host(s)** must be accessible via SSH and support rootless Podman.
- The user must have **sudo** privileges on the target host(s).
- Ensure the host uses a Linux distribution compatible with Podman and SELinux, such as Fedora, CentOS, or RHEL.

## Playbook Tasks

This playbook performs the following tasks in order:
1. Installs **Podman** and **Podman-docker**.
2. Installs **SELinux** dependencies.
3. Downloads and installs **GitHub Actions self-hosted runner**.
4. Configures **rootless Podman** for the specified user.
5. Configures **SELinux policies** to allow containers to run.
6. Starts the **GitHub Actions runner service**.

## How to Run the Playbook

### 1. Clone the repository or download the playbook file.

```bash
git clone https://github.com/redhatryan/podman-actions.git
cd podman/actions/latest/iteration.1/
