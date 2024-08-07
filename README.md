# Rootless GitHub Actions Container Building Pipeline with Podman and RHEL
TODO

TODO - ArgoCD webhook receiver with K8s secret for GHA token refresh

### Dependencies:
* OpenShift Baremetal cluster with ODF
  * TODO
* Installed Operators
  * OpenShift Virtualization Operator
  * TODO
* RHEL Subscription [Activation Keys](https://console.redhat.com/insights/connector/activation-keys) (for Pod software installation)
  * Subscription Org
  * Subscription Key

### Setup Environment
NOTE: Setup is ran from the desired bastion host for the OCP cluster(s)
```sh
sudo dnf install -y git
git clone https://github.com/redhatryan/podman-actions.git ~/
cd ~/
./setup.sh
```

### Deploy
Log into the OpenShift Cluster

Run the demo script from the same bastion to create a fresh RHEL9 VM in a new namespace (first argument or prompt, defaults to last namespace used or ```validated-pattern```)
```sh
cd deploy/
./generate-yaml.sh validated-pattern
oc apply -f validated-pattern.yaml
```
Wait for installation (approximately 4 mins in normal circumstances)

### Demo Highlights
Under Administrator Perspective:
* Operators -> OperatorHub
  * OpenShift Virtualization Operator (installed)
  * Migration Toolkit for Virtualization Operator (available)
* Virtualization
  * Overview
  * Templates
  * DataStore (RWX)
  * Catalog
  * VirtualMachines
    * Create
      * With Wizard
        * Create
          * Select Red Hat Enterprise Linux 9.0 VM
          * Next
            * Create virtual machine
    * [... menu] Migrate Node to Node
    * [New VM] Overview
      * Virtual Machine options
      * Metrics
      * Snapshots
* Run demo steps 
  * Pick random/suggested name for namespace to pass as first argument or when prompted
  * Execute generate and apply steps in shared terminal window showing VirtualMachines screen in the background 

Under the Developer Perspective:
* Topology
  * Show the mixed environment and dig into details
    * 3 Elasticsearch VMs for data and control plane
    * 1 Elasticsearch container as coordinator node
    * 1 Kibana container for data visualization
    * 1 RHEL 9 container for data generation
    * 1 RHEL 9 container for utilities to explore with ssh keys to the VMs

Under Administrator Perspective:
* Networking
   * Routes
     * Select es-master00 Cockpit route
       * Log-in using ```elasticsearch```:```redhat```
         * View services and search for elasticsearch (will appear when ready)
     * Select elasticsearch route
       * Verify ```cluster_uuid``` is populated
       * Append ```/_cat/nodes``` to elasticsearch url and verify ```coordinate``` is a member
     * Open kibana route to show connected web application
       * In Kibana create a new discovery for the "generated" index with timestamp
* Virtualization
  * VirtualMachines
    * es-master00
      * Environment
        * Configuration Maps mounted inside the VM
          * 00yaml - Elasticsearch Node specific configuration
          * 0000sh - Multiple scripts used during VM installation
        * Secret mounted inside the VM
          * 00cert - Let's Encrypt SSL Certificate private key and chain used by the VMs
    * Migrate VM from Node to Node
    * Take a Snapshot of the VM