variable "account_id" {
  description = "The account id for Cloudflare"
  type        = string
}

variable "zone_id" {
  description = "The DNS zone id for Cloudflare"
  type        = string
}

variable "email" {
  description = "The email to send notifications"
  type        = string
}

variable "hostname_fqdn" {
  description = "The FQDN used for the Tunnel"
  type        = string
}

variable "hostname_dns_record" {
  description = "The hostname used for creating the DNS record"
  type        = string
}