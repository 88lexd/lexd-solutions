# OS Configuration
This section contains Ansible playbooks for configuring the underlying EC2 Operating System (Ubuntu 20.04).

## Install Ansible and Dependencies
Should install the newer version of Ansible (ansible-core)
```
$ sudo apt install python3-pip

# Remove any existing ansible install
$ apt remove ansible
$ pip uninstall ansible

# Install latest ansible using pip (run as non root user, will this install for the current user)
$ pip install ansible

# Confirm is for current user only
$ ansible --version
ansible [core 2.11.5]
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/home/alex/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /home/alex/.local/lib/python3.8/site-packages/ansible
  ansible collection location = /home/alex/.ansible/collections:/usr/share/ansible/collections
  executable location = /home/alex/.local/bin/ansible
  python version = 3.8.10 (default, Jun  2 2021, 10:49:15) [GCC 9.4.0]
  jinja version = 2.10.1
  libyaml = True

# Install Kubernetes modules
$ ansible-galaxy collection install kubernetes.core
```
Note: Install the collection by using standard account (not root). The collection will be saved to `~/.ansible/collections`

## How to Run Playbook
The playbook will take in the inventory file (inventory.txt) and will configure the servers as defined.

This playbook was developed when I had 2x VM running locally. On AWS, we will just be starting off with 1x EC2 instance to keep cost to the minimum. The single node will be the master node.

Update the `inventory.ini` with the server IP and then run:

Note: When prompt, enter the Ansible vault password which was used to encrypt the MySQL password variable.

```
# Example:

$ ansible-playbook -i inventory.ini main.yml -u ubuntu --private-key ~/.ssh/my-key.pem --ask-vault-pass
Vault password:

PLAY [masternode,workernode] ******************************************************************************************************************************************

TASK [Gathering Facts] ************************************************************************************************************************************************
ok: [workernode]
ok: [masternode]

TASK [Apply base configuration] ***************************************************************************************************************************************
included: /home/alex/code/git/lexd-solutions/aws-wordpress/2-os-configuration/ansible_tasks/base-config.yml for masternode, workernode

TASK [Set timezone to Australia/Sydney] *******************************************************************************************************************************
ok: [masternode]
ok: [workernode]

TASK [Configure .vimrc (no indent)] ***********************************************************************************************************************************
changed: [workernode]
changed: [masternode]

TASK [Configure .vimrc (set paste)] ***********************************************************************************************************************************
changed: [masternode]
changed: [workernode]

TASK [Install base dependencies] **************************************************************************************************************************************
changed: [masternode]
changed: [workernode]

TASK [Install and configure MicroK8s] *********************************************************************************************************************************
included: /home/alex/code/git/lexd-solutions/aws-wordpress/2-os-configuration/ansible_tasks/setup-microk8s.yml for masternode, workernode

TASK [Get latest stable version number for kubectl] *******************************************************************************************************************
ok: [masternode]
ok: [workernode]

TASK [Download the latest stable version of kubectl] ******************************************************************************************************************
changed: [masternode]
changed: [workernode]

TASK [Install microk8s with option --channel=1.21/stable] *************************************************************************************************************
changed: [workernode]
changed: [masternode]

TASK [Add current user [alex] into microk8s group] ********************************************************************************************************************
changed: [masternode]
changed: [workernode]

TASK [Enable microk8s addons] *****************************************************************************************************************************************
changed: [workernode]
changed: [masternode]

TASK [Configure host kubectl (instead of running 'microk8s kubectl' every time)] **************************************************************************************
ok: [masternode]
ok: [workernode]

TASK [Configure kube config for current user with auto complete for bash] *********************************************************************************************
changed: [masternode]
changed: [workernode]

TASK [Install helm binary] ********************************************************************************************************************************************
changed: [workernode]
changed: [masternode]

TASK [Move helm to desired destination] *******************************************************************************************************************************
changed: [masternode]
changed: [workernode]

TASK [Append Master Node IP into /etc/hosts] **************************************************************************************************************************
changed: [masternode]
changed: [workernode]

TASK [Append Worker Node IP into /etc/hosts] **************************************************************************************************************************
changed: [masternode]
changed: [workernode]

TASK [Setup NFS Server on Master Node] ********************************************************************************************************************************
skipping: [workernode]
included: /home/alex/code/git/lexd-solutions/aws-wordpress/2-os-configuration/ansible_tasks/setup-nfs-server.yml for masternode

TASK [Install NFS package] ********************************************************************************************************************************************
changed: [masternode]

TASK [Create directory for NFS exports for Prod] **********************************************************************************************************************
changed: [masternode]

TASK [Create NFS export for Prod] *************************************************************************************************************************************
changed: [masternode]

TASK [Enable and restart NFS service] *********************************************************************************************************************************
changed: [masternode] => (item=nfs-server)
changed: [masternode] => (item=nfs-idmapd)

TASK [Install nfs-subdir-external-provisioner for Dynamic Storage Provisioning] ***************************************************************************************
changed: [masternode]

PLAY RECAP ************************************************************************************************************************************************************
masternode                 : ok=24   changed=17   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
workernode                 : ok=18   changed=12   unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
```

## Configure Multi Node for MicroK8s
The playbook does not configure for Multi Node cluster. The following must be ran manually:

**ON THE MASTER NODE**, run the `microk8s add-node` command.
```
alex@ubuntu-k3s-01:~$ microk8s add-node
From the node you wish to join to this cluster, run the following:
microk8s join 192.168.198.101:25000/184b0330dd1cf5e56bb445c249990491/610fb48e24a8

If the node you are adding is not reachable through the default interface you can use one of the following:
 microk8s join 192.168.198.101:25000/184b0330dd1cf5e56bb445c249990491/610fb48e24a8
```

**ON THE WORKER NODE**, run the `microk8s join` command from the output above
```
alex@ubuntu-k3s-02:~$ microk8s join 192.168.198.101:25000/184b0330dd1cf5e56bb445c249990491/610fb48e24a8
```
