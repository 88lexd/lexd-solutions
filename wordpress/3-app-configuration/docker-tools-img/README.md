# Docker Tools Image
This Docker image contains tools for me to test/troubleshoot pods connectivity within Kubernetes.

## Build Image and Test
```
# Build image
$ docker build . -t 88lexd/tools

# Start a container
$ docker run --rm -d --name tools 88lexd/tools

# Exec into the container
$ docker exec -it tools bash
root@d4076298acd0:~# ping -c2 google.com
PING google.com (142.250.66.238) 56(84) bytes of data.
64 bytes from syd15s15-in-f14.1e100.net (142.250.66.238): icmp_seq=1 ttl=111 time=16.7 ms
64 bytes from syd15s15-in-f14.1e100.net (142.250.66.238): icmp_seq=2 ttl=111 time=17.0 ms

--- google.com ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1001ms
rtt min/avg/max/mdev = 16.711/16.860/17.010/0.149 ms
root@d4076298acd0:~#

# Stop (which will auto remote (thanks to --rm)) the container
$ docker stop tools
```

## Manual Push to Docker Hub
For whatever reason I need to manually push this image up to Docker Hub, then use the following command:
```
$ docker login
# Login with creds

$ docker push 88lexd/tools
```

## Deploy a pod with this image
```
$ kubectl run tools --image=88lexd/tools

$ kubectl exec -it tools -- bash
root@tools:~# curl google.com.
<HTML><HEAD><meta http-equiv="content-type" content="text/html;charset=utf-8">
<TITLE>301 Moved</TITLE></HEAD><BODY>
<H1>301 Moved</H1>
The document has moved
<A HREF="http://www.google.com/">here</A>.
</BODY></HTML>
root@tools:~#
```
