# OS Configuration (main.yml)
This section contains Ansible playbooks for configuring the underlying EC2 Operating System (Ubuntu 20.04).

## Important Note
As of 10.12.2021, I am building out a new Kubernetes cluster to replace the initial MicroK8s deployment. This new playbook will:
 1) Use 2 nodes in a cluster instead of 1.
 2) Install and configure Kubernetes using `kubeadm` instead of using MicroK8s.
 3) Install and configure GlusterFS to provide High Availability for storage across the 2 nodes.

For those coming from my early blog posts, these old files can still be referenced in the `./old-microk8s` directory.

## Install Ansible and Dependencies
Install Ansible (ansible-core) through pip. Also install jmespath for "json_query" function.
```
$ sudo apt install python3-pip python3-jmespath

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
This new playbook uses Ansible roles to perform the following:

 1) Base OS configuration with my personal settings.
 2) Install and configure GlusterFS on 3 servers (2 replica + 1 arbiter). This will enable HA (High Availability) for volumes in Kubernetes.
 3) Install and configre Kubernetes using kubeadm.


# Troubleshooting
## CoreDNS issue
On the first OS configuration. CoreDNS pods uses the default 10.244.0.0/16 CIDR. Since I had configured weavenet to use the 172.16.0.0/16 subnet I had to restart the coredns deployment to fix DNS issues within the cluster.

```
# Run the following command:
$ kubectl -n kube-system rollout restart deployment coredns
```
