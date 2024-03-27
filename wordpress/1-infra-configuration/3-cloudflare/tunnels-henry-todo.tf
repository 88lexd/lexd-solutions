# This specific configuration is to setup the tunnel for Henry's todo app
locals {
  henry_todo = {
    zone_id = "ef52cbbc77074d3566c6687589e98de9"
    hostname_fqdn = "todo.henrydinh.net"
    hostname_dns_record = "todo"
  }
}

resource "random_string" "tunnel_secret_henry_todo_app" {
  length  = 32
  special = true
}

resource "cloudflare_tunnel" "henry_todo_app" {
  account_id = var.account_id
  name       = "henry-todo-app"
  secret     = base64encode(random_string.tunnel_secret_henry_todo_app.result)
}

resource "cloudflare_tunnel_config" "henry_todo_app" {
  account_id = var.account_id
  tunnel_id  = cloudflare_tunnel.henry_todo_app.id

  config {
    ingress_rule {
      hostname = local.henry_todo.hostname_fqdn
      path     = "/"
      service  = "http://192.168.0.23"
    }

    ingress_rule {
      service = "http_status:404"
    }
  }
}

resource "cloudflare_record" "henry_todo_app" {
  zone_id = local.henry_todo.zone_id
  name    = local.henry_todo.hostname_dns_record
  value   = "${cloudflare_tunnel.henry_todo_app.id}.cfargotunnel.com"
  type    = "CNAME"
  proxied = true
}
