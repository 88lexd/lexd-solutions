# App Configuration
This Helm Chart is **created from scratch** to meet my own requirements.

# How to Deploy this Helm Chart
First copy the helm chart over to the remote server (unless local kubectl is configured to connect to remote server)

```
$ scp -r -i ~/.ssh/my.pem . ubuntu@<remote-server>:
```

SSH onto remote server and continue the below (helm is installed on server server via Ansible)

## Install Prod
Note: Namespace is created by Ansible during setup
```
$ helm install wordpress-prod . --namespace=prod --values=values-prod.yaml
```

## Install Dev
Note: Namespace is created by Ansible during setup
```
$ helm install wordpress-dev . --namespace=dev --values=values-dev.yaml
```

## Install Dev Local
Note: Namespace is created by Ansible during setup
```
$ helm install wordpress-dev . --namespace=dev --values=values-dev-local.yaml
```

# Troubleshooting
Initial start, we get a database connection error "Error establishing a database connection"

To debug, enable the debug to 'true' for the following file
```
$ kubectl exec -it -n prod wordpress-c8d679979-5q6g2 -- bash

$ cat /var/www/html/wp-config.php | grep "WORDPRESS_DEBUG"
define( 'WP_DEBUG', !!getenv_docker('WORDPRESS_DEBUG', '') );

# No vi in container. Ekubedit the file from NFS server: Set the line above to:
$ sudo vi /nfs/k8s/prod-wordpress-pvc-pvc-39f03258-1d13-40bc-bd44-a795a6eb32f6/wp-config.php

define( 'WP_DEBUG', true );
```


Once debug is enabled, we see the error "Unknown database 'wordpress'". Log onto the mysql container and create the DB. Example:

```
$ kubectl exec -it -n prod mysql-wordpress-65f6d678d9-2s4ss -- bash
root@mysql-wordpress-65f6d678d9-2s4ss:/# mysql -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 5
Server version: 5.6.51 MySQL Community Server (GPL)

Copyright (c) 2000, 2021, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> create database wordpress;
Query OK, 1 row affected (0.02 sec)

mysql> quit
Bye
```
