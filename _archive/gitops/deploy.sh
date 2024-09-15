#!/bin/bash

# Function to prompt the user for input
prompt_for_input() {
  read -p "$1: " input
  echo $input
}

# Prompt the user for required fields
namespace=$(prompt_for_input "Enter the namespace")
username=$(prompt_for_input "Enter the Red Hat subscription username")
password=$(prompt_for_input "Enter the Red Hat subscription password")
storage_class=$(prompt_for_input "Enter the storage class")
github_repo_url=$(prompt_for_input "Enter the GitHub repository URL")
github_org=$(prompt_for_input "Enter the GitHub organization name")

# Create directory structure
mkdir -p deployments/base deployments/overlays/production ansible-playbook

# Generate base kustomization.yaml
cat <<EOF > deployments/base/kustomization.yaml
resources:
  - pvc.yaml
  - rhel-vm.yaml
EOF

# Generate pvc.yaml
cat <<EOF > deployments/base/pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: rhel-pvc
  namespace: $namespace
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 50Gi
  storageClassName: $storage_class
EOF

# Generate rhel-vm.yaml
cat <<EOF > deployments/base/rhel-vm.yaml
apiVersion: kubevirt.io/v1
kind: VirtualMachine
metadata:
  name: rhel-vm
  namespace: $namespace
spec:
  running: false
  template:
    metadata:
      labels:
        kubevirt.io/domain: rhel-vm
    spec:
      domain:
        devices:
          disks:
            - disk:
                bus: virtio
              name: rootdisk
        resources:
          requests:
            memory: 4Gi
      volumes:
        - name: rootdisk
          persistentVolumeClaim:
            claimName: rhel-pvc
        - cloudInitNoCloud:
            userData: |
              #cloud-config
              runcmd:
                - subscription-manager register --username $username --password $password
                - subscription-manager attach --auto
                - subscription-manager repos --enable=rhel-7-server-rpms
                - yum -y update
                - yum -y install ansible
                - doppler run -- ansible-pull -U https://github.com/$github_org/ansible-playbook.git -i localhost, ansible-playbook/podman-setup.yaml
EOF

# Generate ansible-playbook/podman-setup.yaml
cat <<EOF > ansible-playbook/podman-setup.yaml
---
- hosts: localhost
  become: yes
  tasks:
    - name: Install Podman and dependencies
      yum:
        name:
          - podman
          - podman-docker
        state: present

    - name: Ensure SELinux is enforcing
      command: setenforce 1

    - name: Install policycoreutils-python-utils
      yum:
        name: policycoreutils-python-utils
        state: present

    - name: Create runner user
      user:
        name: runner
        shell: /bin/bash
        create_home: yes

    - name: Configure sudoers for runner user
      lineinfile:
        path: /etc/sudoers
        state: present
        line: 'runner ALL=(ALL) NOPASSWD:ALL'

    - name: Download GitHub Actions runner
      become_user: runner
      get_url:
        url: https://github.com/actions/runner/releases/download/v2.283.3/actions-runner-linux-x64-2.283.3.tar.gz
        dest: /home/runner/actions-runner.tar.gz

    - name: Extract GitHub Actions runner
      become_user: runner
      unarchive:
        src: /home/runner/actions-runner.tar.gz
        dest: /home/runner/
        remote_src: yes

    - name: Install dependencies for runner
      become_user: runner
      command: /home/runner/actions-runner/bin/installdependencies.sh

    - name: Configure GitHub Actions runner
      become_user: runner
      command: /home/runner/actions-runner/config.sh --url $github_repo_url --token \$RUNNER_TOKEN
      environment:
        RUNNER_TOKEN: "{{ lookup('env', 'RUNNER_TOKEN') }}"

    - name: Install runner as a service
      become_user: runner
      command: /home/runner/actions-runner/svc.sh install

    - name: Enable and start runner service
      systemd:
        name: actions.runner.service
        enabled: yes
        state: started
EOF

# Generate production overlay kustomization.yaml
cat <<EOF > deployments/overlays/production/kustomization.yaml
bases:
  - ../../base

patchesStrategicMerge:
  - patches.yaml
EOF

# Generate production overlay patches.yaml
cat <<EOF > deployments/overlays/production/patches.yaml
apiVersion: kubevirt.io/v1
kind: VirtualMachine
metadata:
  name: rhel-vm
  namespace: $namespace
spec:
  running: true
EOF

# Deploy the manifests using kubectl
kubectl apply -k deployments/overlays/production

# Prompt user to set up Doppler
doppler setup

# Fetch Doppler secrets and export them as environment variables
doppler run --export > .env

# Run Ansible playbook with Doppler secrets
ansible-pull -U https://github.com/$github_org/ansible-playbook.git -i localhost, ansible-playbook/podman-setup.yaml -e @.env

echo "Deployment completed successfully."
