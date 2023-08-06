resource "cloudflare_zone" "lexdsolutions" {
  account_id = var.account_id
  zone       = "lexdsolutions.com"
}

resource "cloudflare_zone_settings_override" "lexdsolutions" {
  zone_id = cloudflare_zone.lexdsolutions.id

  settings {
    # Turn on development_mode to temporarily bypass cache and see changess from the origin server in realtime
    development_mode = "off"
    brotli           = "on"
    always_use_https = "on"
    ssl              = "full" # off| flexible | full | strict
  }
}
