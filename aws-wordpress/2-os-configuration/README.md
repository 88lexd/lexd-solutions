# OS Configuration
This section contains Ansible playbooks for configuring the underlying EC2 Operating System (Ubuntu 20.04).

## The old MicroK8s Playbook
**IMPORTANT:** As of 10.12.2021, I am building out a new Kubernetes cluster that is deployed using `kubeadm` and this will be replacing the initial MicroK8s cluster.

For those coming from my early blog posts, these old files can be referenced in the `./old-microk8s` directory.


## Install Ansible and Dependencies
Install Ansible (ansible-core) through pip.
```
$ sudo apt install python3-pip

# Remove any existing ansible install
$ sudo apt remove ansible
$ pip uninstall ansible

# Install latest ansible using pip (run as non root user, will this install for the current user)
$ pip install ansible

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
$ ansible-galaxy collection install kubernetes.core
```
Note: Install the collection by using standard account (not root). The collection will be saved to `~/.ansible/collections`

## How to Run Playbook
This playbook will install and configure Kubernetes using kubeadm on 2 nodes.

It will also setup GlusterFS for shared volume between the nodes. This enables HA (High Availability) so when one node goes down, WordPress can still function seamlessly.

