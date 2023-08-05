# Cloudflare
Cloudflare is used to front my website by providing CDN, WAF and DDoS protection.

This directory contains the Terraform IaC to define the Cloudflare configuration.

## Authentication
The Cloudflare API key is used to authenticate into my account. Local environmental variable is used:
```
echo 'export CLOUDFLARE_API_KEY="123"' >> ~/.bashrc.alex
echo 'export CLOUDFLARE_EMAIL="myemail@domain.com"' >> ~/.bashrc.alex
```

## Prerequisites
First setup the zone in Cloudflare
```
terraform init
terraform apply -target cloudflare_zone.lexdsolutions
```

DNS is required to be hosted by Cloudflare. I need to migrate my existing records from AWS Route53 to Cloudflare.

 - Manually port records over to Cloudflare DNS
 - Update DNS registrar to use Cloudflare Name Servers
 - Ensure Top Level domain (lexdsolutions.com) record is **proxied** through CloudFlare

## Deploy Remaining CloudFlare Configuration
This Terraform IaC will configure the remaining settings for this zone, such as enabling cache, WAF and DDoS protections.

```
terraform plan -out tfplan.out
terraform apply tfplan.out
```

### Local Testing
Due to the lag in DNS replication on the internet, to test the Cloudflare protections, I must modify my local `hostfile` to point to the CloudFlare's edge IPs for my DNS.

First get the IP by quering CloudFlare Name Server
```
alex@LEXD-PC:~$ nslookup
> server bob.ns.cloudflare.com  <------- Set to query Cloudflare
Default server: bob.ns.cloudflare.com
Address: 173.245.59.104#53
Default server: bob.ns.cloudflare.com
Address: 172.64.33.104#53
Default server: bob.ns.cloudflare.com
Address: 108.162.193.104#53
Default server: bob.ns.cloudflare.com
Address: 2606:4700:58::adf5:3b68#53
Default server: bob.ns.cloudflare.com
Address: 2803:f800:50::6ca2:c168#53
Default server: bob.ns.cloudflare.com
Address: 2a06:98c1:50::ac40:2168#53
> lexdsolutions.com  <------- query my record
Server:         bob.ns.cloudflare.com
Address:        173.245.59.104#53

Name:   lexdsolutions.com
Address: 104.21.51.90  <------- Take note of this record (can be any from this response)
Name:   lexdsolutions.com
Address: 172.67.177.252
Name:   lexdsolutions.com
Address: 2606:4700:3034::ac43:b1fc
Name:   lexdsolutions.com
Address: 2606:4700:3037::6815:335a
```

Modify local `hostfile` to point `lexdsolutions => 104.21.51.90`
