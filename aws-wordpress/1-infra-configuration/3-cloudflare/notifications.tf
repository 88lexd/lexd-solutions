resource "cloudflare_notification_policy" "tunnel_health" {
  account_id  = var.account_id
  name        = "lexd-tunnel-health-alert"
  description = "Send notification when tunnel is down"
  enabled     = true
  alert_type  = "tunnel_health_event"

  email_integration {
    id = var.email
  }

  filters {
    tunnel_id = [cloudflare_tunnel.lexd_solutions.id]
  }
}
