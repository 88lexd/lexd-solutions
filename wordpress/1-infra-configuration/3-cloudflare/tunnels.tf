resource "random_string" "tunnel_secret" {
  length  = 32
  special = true
}

resource "cloudflare_tunnel" "lexd_solutions" {
  account_id = var.account_id
  name       = "lexd-solutions"
  secret     = base64encode(random_string.tunnel_secret.result)
}

resource "cloudflare_tunnel_config" "lexd_solutions" {
  account_id = var.account_id
  tunnel_id  = cloudflare_tunnel.lexd_solutions.id

  config {
    ingress_rule {
      hostname = var.hostname_fqdn
      path     = "/"
      service  = "http://192.168.0.23"
    }

    ingress_rule {
      service = "http_status:404"
    }
  }
}

resource "cloudflare_record" "lexd_solutions" {
  zone_id = var.zone_id
  name    = var.hostname_dns_record
  value   = "${cloudflare_tunnel.lexd_solutions.id}.cfargotunnel.com"
  type    = "CNAME"
  proxied = true
}
