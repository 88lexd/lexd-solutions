# Supernetting (Route Summarization)
In subnetting, a single large network is split into smaller subnetworks. Supernetting is when multiple networks are combined into a larger network.

This is very useful when you want to combine the multiple subnets into a single CIDR.

**Example subnets:**
```
192.168.0.0/24
192.168.1.0/24
192.168.2.0/24
192.168.3.0/24
```

After supernetting, we can replace these 4 CIDRs with `192.168.0.0/22`

## Setup
Run `setup.sh` to configure Python virtual environment and libraries
```
$ bash setup.sh
created virtual environment CPython3.8.10.final.0-64 in 115ms
  creator CPython3Posix(dest=/home/alex/code/git/lexd-solutions/misc-scripts/python-supernetting/venv, clear=False, global=False)
  seeder FromAppData(download=False, pip=latest, setuptools=latest, wheel=latest, pkg_resources=latest, via=copy, app_data_dir=/home/alex/.local/share/virtualenv/seed-app-data/v1.0.1.debian.1)
  activators BashActivator,CShellActivator,FishActivator,PowerShellActivator,PythonActivator,XonshActivator
Collecting netaddr
  Downloading netaddr-0.8.0-py2.py3-none-any.whl (1.9 MB)
     |████████████████████████████████| 1.9 MB 1.6 MB/s
Collecting ipaddress
  Downloading ipaddress-1.0.23-py2.py3-none-any.whl (18 kB)
Installing collected packages: netaddr, ipaddress
Successfully installed ipaddress-1.0.23 netaddr-0.8.0
```
