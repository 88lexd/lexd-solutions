# Important Note 1
As of Jan 2022, I've created a new Kubernetes cluster to replace the initial MicroK8s deployment.

In this new setup, I am using 2 nodes (1x Master / 1x Worker) in a cluster instead of 1 MicroK8s node.

For those coming from my early blog posts, these old files can still be referenced in the `./old-microk8s` directory.

# Important Note 2
As of early 2024, I've migated out from AWS and is now self hosted. Some changes have been made for deploying to a non AWS machine.

# OS Configuration
This section contains the Ansible playbook for configuring the underlying Operating System (Ubuntu 22.04) to run Kubernetes.

## Install Ansible and Dependencies
Install Ansible (ansible-core) through pip.
```
$ sudo apt install python3-pip

# Remove any existing ansible install
$ sudo apt remove ansible
$ pip uninstall ansible

# Install latest ansible using pip (run as non root user, will this install for the current user)
$ pip install ansible

# If required, update $PATH to where Ansible is installed.
$ echo 'export PATH=$PATH:~/.local/bin/' >> ~/.bashrc

# Confirm is for current user only
$ ansible --version
ansible [core 2.12.1]
  config file = None
  configured module search path = ['/home/alex/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /home/alex/.local/lib/python3.8/site-packages/ansible
  ansible collection location = /home/alex/.ansible/collections:/usr/share/ansible/collections
  executable location = /home/alex/.local/bin/ansible
  python version = 3.8.10 (default, Sep 28 2021, 16:10:42) [GCC 9.3.0]
  jinja version = 2.10.1
  libyaml = True

# Install Kubernetes modules
$ ansible-galaxy collection install kubernetes.core community.general ansible.posix
```
Note: Install the collection by using standard account (not root). The collection will be saved to `~/.ansible/collections`

## What this Playbook does
This playbook will configure the following:

 1) Apply base OS configuration with my personal settings on all nodes
 2) <del>Install and Setup CloudWatch agent on all nodes</del>
 3) Install and configure Containerd as the Container Runtime on all nodes
 4) Prepare nodes for Kubernetes install (e.g. disabling swap, configuring br_netfilter etc.)
 5) Install Kubernetes packages on all nodes (e.g. kubeadm, kubectl, kubelet)
 6) Create Kubernetes cluster by using kubeadm
 7) Join worker node to cluster
 8) Apply cluster config such as deploying existing secrets and creating namespaces
 9) Install and setup Nginx Ingress Controller
 10) <del>Install and setup NFS-Subdir External Provisioner (this enables dynamic PV provisioning on EFS)</del>
 10) Install and setup local-path-provisioner (this enables dynamic PV provisioning on local disk for simplicity)</del>

## How to run the playbook:
Use the following:
```
$ ansible-playbook -i inventory_local.ini main.yml --ask-vault-pass
```

# Troubleshooting
## CoreDNS issue
On the initial OS configuration. CoreDNS pods uses the default 10.244.0.0/16 CIDR. Since I had configured weavenet to use the 172.16.0.0/16 subnet I had to restart the coredns deployment to fix DNS issues within the cluster.

To fix this, I had to run the following command:
```
$ kubectl -n kube-system rollout restart deployment coredns
```

## Containers exiting on Containerd
When I uplifted the code to deploy a newer version of Kubernetes (v1.29), containers were failing to start or is starting but existing immediately. The following was used to help troubleshoot

- SSH onto the master node
- Run the following command to view all running containers
  ```
  $ sudo crictl -r unix:///run/containerd/containerd.sock ps -a
  CONTAINER           IMAGE               CREATED             STATE               NAME                      ATTEMPT             POD ID              POD
  f1e75514677a6       cbb01a7bd410d       21 hours ago        Running             coredns                   0                   d963255827ada       coredns-76f75df574-g8f22
  b2bbed6883251       cbb01a7bd410d       21 hours ago        Running             coredns                   0                   3e409458f072d       coredns-76f75df574-tzz99
  47d738d26e9ce       f9c73fde068fd       21 hours ago        Running             kube-flannel              0                   2fb75ca4be652       kube-flannel-ds-96mt8
  4b45820c832f3       f9c73fde068fd       21 hours ago        Exited              install-cni               0                   2fb75ca4be652       kube-flannel-ds-96mt8
  16294878ee89a       77c1250c26d96       21 hours ago        Exited              install-cni-plugin        0                   2fb75ca4be652       kube-flannel-ds-96mt8
  8ec44c565d606       a0eed15eed449       22 hours ago        Running             etcd                      6                   5c048be2fd78d       etcd-masternode
  fdace94d78b49       6fc5e6b7218c7       22 hours ago        Running             kube-scheduler            8                   4fa65020b96b8       kube-scheduler-masternode
  a2a7c7d559bec       138fb5a3a2e34       22 hours ago        Running             kube-controller-manager   8                   77a6b7f3d4c98       kube-controller-manager-masternode
  8ac2841c99e27       8a9000f98a528       22 hours ago        Running             kube-apiserver            4                   25ca960c5f830       kube-apiserver-masternode
  56e7a9ba7ca98       a0eed15eed449       22 hours ago        Exited              etcd                      5                   08da439a52a9a       etcd-masternode
  44f086d065422       6fc5e6b7218c7       22 hours ago        Exited              kube-scheduler            7                   39bd90e097c55       kube-scheduler-masternode
  49c338919a4b3       138fb5a3a2e34       22 hours ago        Exited              kube-controller-manager   7                   1de94e940a0db       kube-controller-manager-masternode
  31d8e3ab217be       8a9000f98a528       22 hours ago        Exited              kube-apiserver            3                   c82c058dceed7       kube-apiserver-masternode
  ```
- View the logs by running:
  ```
  $ sudo crictl -r unix:///run/containerd/containerd.sock logs <container-id>
  ```
