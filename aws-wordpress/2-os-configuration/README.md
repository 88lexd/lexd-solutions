# Important Note
As of Jan 2022, I've created a new Kubernetes cluster to replace the initial MicroK8s deployment. This new playbook will:

In this new setup, I am using 2 nodes (1x Master / 1x Worker) in a cluster instead of 1 MicroK8s node.

For those coming from my early blog posts, these old files can still be referenced in the `./old-microk8s` directory.

# OS Configuration
This section contains the Ansible playbook for configuring the underlying EC2 Operating System (Ubuntu 20.04) to run Kubernetes.

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
This new playbook will configure the following:

 1) Apply base OS configuration with my personal settings on all nodes
 2) Install and Setup CloudWatch agent on all nodes
 3) Install and configure Docker Container Runtime on all nodes
 4) Prepare nodes for Kubernetes install (e.g. disabling swap, configuring br_netfilter etc.)
 5) Install Kubernetes packages on all nodes (e.g. kubeadm, kubectl, kubelet)
 6) Create Kubernetes cluster by using kubeadm
 7) Join worker node to cluster
 8) Apply cluster config such as deploying existing secrets and creating namespaces
 9) Install and setup Nginx Ingress Controller
 10) Install and setup NFS-Subdir External Provisioner (this enables dynamic PV provisioning on EFS)


# Troubleshooting
## CoreDNS issue
On the initial OS configuration. CoreDNS pods uses the default 10.244.0.0/16 CIDR. Since I had configured weavenet to use the 172.16.0.0/16 subnet I had to restart the coredns deployment to fix DNS issues within the cluster.

To fix this, I had to run the following command:
```
$ kubectl -n kube-system rollout restart deployment coredns
```
