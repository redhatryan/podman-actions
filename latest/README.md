# Rootless Podman with GitHub Actions and SELinux Setup

This repository provides a structured, iterative solution to deploy rootless Podman for use with GitHub Actions runners and configure SELinux policies on Linux systems. The goal is to start with a simple Ansible playbook, then progressively refactor it into roles and collections to increase modularity, scalability, and ease of sharing.

## Purpose

The primary goal of this solution is to:
- Set up **rootless Podman** to enable secure, non-root container management.
- Deploy a **GitHub Actions self-hosted runner** to automate CI/CD pipelines.
- **Configure SELinux** for container security, ensuring proper permissions for the runner and Podman.

This solution is designed to be iterative, providing a foundation that evolves into a more sophisticated, reusable framework.

## Iterations

The solution is built over three iterations:

### Iteration 1: Simple Playbook

In the first iteration, we start with a single, monolithic Ansible playbook that performs the following tasks:
- Install Podman and Podman-docker.
- Install SELinux dependencies.
- Download and install the GitHub Actions self-hosted runner.
- Enable rootless Podman for the user.
- Configure SELinux for container management.
- Start the GitHub Actions runner service.

#### Example Playbook (Iteration 1):

```yaml
---
- name: Set up rootless Podman for GitHub Actions with SELinux
  hosts: all
  become: yes

  tasks:
    - name: Install Podman and Podman-docker
      package:
        name:
          - podman
          - podman-docker
        state: present

    - name: Install SELinux dependencies
      package:
        name:
          - selinux-policy
          - selinux-policy-targeted
          - policycoreutils
          - policycoreutils-python-utils
        state: present

    - name: Download and install GitHub Actions self-hosted runner
      tasks to download, extract, and install runner...

    - name: Enable rootless Podman
      shell: loginctl enable-linger {{ ansible_user }}

    - name: Configure SELinux for Podman and GitHub Actions runner
      command: setsebool container_manage_cgroup 1
