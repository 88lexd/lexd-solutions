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

## How to run
Create a file containing subnets. Example:
```
$ cat subnets.txt
10.156.216.0/21
10.156.212.0/22
10.60.0.0/16
10.61.0.0/16
10.50.1.0/24
10.70.2.0/24
192.168.0.0/24
192.168.1.0/24
192.168.2.0/24
192.168.3.0/24
```

Run the python script to summarize networks.
```
$ ./venv/bin/python3 supernet.py --file subnets.txt
================================
Supernetting Script by Alex Dinh
================================
Reading from - /home/alex/code/git/lexd-solutions/misc-scripts/python-supernetting/subnets.txt
Begin supernetting...

10.50.1.0/24 - (first host: 10.50.1.1 | last host: 10.50.1.254) -- cannot be supernetted
10.60.0.0/16 - (first host: 10.60.0.1 | last host: 10.60.255.254) -- is supernetted
10.61.0.0/16 - (first host: 10.61.0.1 | last host: 10.61.255.254) -- is supernetted
10.70.2.0/24 - (first host: 10.70.2.1 | last host: 10.70.2.254) -- cannot be supernetted
10.156.212.0/22 - (first host: 10.156.212.1 | last host: 10.156.215.254) -- cannot be supernetted
10.156.216.0/21 - (first host: 10.156.216.1 | last host: 10.156.223.254) -- cannot be supernetted
192.168.0.0/24 - (first host: 192.168.0.1 | last host: 192.168.0.254) -- is supernetted
192.168.1.0/24 - (first host: 192.168.1.1 | last host: 192.168.1.254) -- is supernetted
192.168.2.0/24 - (first host: 192.168.2.1 | last host: 192.168.2.254) -- is supernetted
192.168.3.0/24 - (first host: 192.168.3.1 | last host: 192.168.3.254) -- is supernetted

========================
New Supernetted Subnets:
========================
10.50.1.0/24 - (first host: 10.50.1.1 | last host: 10.50.1.254)
10.60.0.0/15 - (first host: 10.60.0.1 | last host: 10.61.255.254)
10.70.2.0/24 - (first host: 10.70.2.1 | last host: 10.70.2.254)
10.156.212.0/22 - (first host: 10.156.212.1 | last host: 10.156.215.254)
10.156.216.0/21 - (first host: 10.156.216.1 | last host: 10.156.223.254)
192.168.0.0/22 - (first host: 192.168.0.1 | last host: 192.168.3.254)
```
