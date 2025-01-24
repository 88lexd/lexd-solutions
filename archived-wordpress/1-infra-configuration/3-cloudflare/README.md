# Cloudflare
Cloudflare is used to front my website by providing CDN, WAF and DDoS protection.

This directory contains the Terraform IaC to define the Cloudflare configuration.

## Configuration
### Cloudflare
The Cloudflare API key is used to authenticate into my account. Local environmental variable is used:
```
echo 'export CLOUDFLARE_API_KEY="123"' >> ~/.bashrc.alex
echo 'export CLOUDFLARE_EMAIL="myemail@domain.com"' >> ~/.bashrc.alex
```

### Terraform Backend
The Terraform state is stored in AWS S3 alongside with my other IaC.

Note: When I first played with this Cloudflare provider, I was using a local state, but once I added the `backend.tf`, I had to run the following command to migrate my state over to S3. The following commands were used:

```shell
# First auth into AWS
# See: https://github.com/88lexd/lexd-solutions/tree/main/misc-scripts/python-aws-assume-role)
$ assume-role --c cred.yml -r roles.yml

$ export AWS_PROFILE=lexd-admin

# Migrate state over to S3
$ terraform init -migrate-state
$ terraform plan
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

Modify local `hostfile` with the following records for testing:
```
104.21.51.90 lexdsolutions.com
104.21.51.90 www.lexdsolutions.com
```

## Cloudflare Tunnel
Background: Cloudflare tunnel allows me to selfhost my blog and not on AWS. Due to CGNAT limitation, I do not have a dedicated public IP available to use.

Terraform is used to setup the tunnel and once it is setup:
 - Manually log onto Cloudflare dashboard
 - Look for the tunnel
 - Inside the configuration, it provides the command to run `cloudflared` as a container, for example:
    ```
    $ docker run -d --restart unless-stopped cloudflare/cloudflared:latest tunnel --no-autoupdate run --token abc123
    ```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_cloudflare"></a> [cloudflare](#requirement\_cloudflare) | ~> 4.25.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_cloudflare"></a> [cloudflare](#provider\_cloudflare) | ~> 4.25.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [cloudflare_notification_policy.tunnel_health](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/notification_policy) | resource |
| [cloudflare_record.lexd_solutions](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_ruleset.cache](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/ruleset) | resource |
| [cloudflare_ruleset.waf](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/ruleset) | resource |
| [cloudflare_ruleset.www](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/ruleset) | resource |
| [cloudflare_tiered_cache.tier](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/tiered_cache) | resource |
| [cloudflare_tunnel.lexd_solutions](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/tunnel) | resource |
| [cloudflare_tunnel_config.lexd_solutions](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/tunnel_config) | resource |
| [cloudflare_zone.lexdsolutions](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/zone) | resource |
| [cloudflare_zone_settings_override.lexdsolutions](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/zone_settings_override) | resource |
| [random_string.tunnel_secret](https://registry.terraform.io/providers/hashicorp/random/3.6.0/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | The account id for Cloudflare | `string` | n/a | yes |
| <a name="input_email"></a> [email](#input\_email) | The email to send notifications | `string` | n/a | yes |
| <a name="input_hostname_dns_record"></a> [hostname\_dns\_record](#input\_hostname\_dns\_record) | The hostname used for creating the DNS record | `string` | n/a | yes |
| <a name="input_hostname_fqdn"></a> [hostname\_fqdn](#input\_hostname\_fqdn) | The FQDN used for the Tunnel | `string` | n/a | yes |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | The DNS zone id for Cloudflare | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_tunnel_secret_value"></a> [tunnel\_secret\_value](#output\_tunnel\_secret\_value) | n/a |
<!-- END_TF_DOCS -->