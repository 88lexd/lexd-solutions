# This specific configuration is to setup the tunnel for Henry's todo app
locals {
  astro = {
    zone_id = "5cf4cd965a07d20a7a74a14565a2037b"
    hostname_fqdn = "dev.lexdsolutions.com"
    hostname_dns_record = "dev"
  }
}

resource "random_string" "tunnel_secret_astro_app" {
  length  = 32
  special = true
}

resource "cloudflare_tunnel" "astro_app" {
  account_id = var.account_id
  name       = "astro-app"
  secret     = base64encode(random_string.tunnel_secret_astro_app.result)
}

resource "cloudflare_tunnel_config" "astro_app" {
  account_id = var.account_id
  tunnel_id  = cloudflare_tunnel.astro_app.id

  config {
    ingress_rule {
      hostname = local.astro.hostname_fqdn
      path     = "/"
      service  = "http://192.168.0.23"
    }

    ingress_rule {
      service = "http_status:404"
    }
  }
}

resource "cloudflare_record" "astro_app" {
  zone_id = local.astro.zone_id
  name    = local.astro.hostname_dns_record
  value   = "${cloudflare_tunnel.astro_app.id}.cfargotunnel.com"
  type    = "CNAME"
  proxied = true
}
