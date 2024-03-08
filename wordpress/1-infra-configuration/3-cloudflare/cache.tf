resource "cloudflare_tiered_cache" "tier" {
  zone_id    = cloudflare_zone.lexdsolutions.id
  cache_type = "smart"
}

resource "cloudflare_ruleset" "cache" {
  zone_id = cloudflare_zone.lexdsolutions.id
  name    = "cache-settings"
  kind    = "zone"
  phase   = "http_request_cache_settings"

  rules {
    action      = "set_cache_settings"
    description = "cache wp-content"
    enabled     = true
    expression  = "(starts_with(http.request.uri.path, \"/wp-content\"))"
    action_parameters {
      cache = true
      edge_ttl {
        mode    = "override_origin"
        default = 21600 # 6 hours
      }
    }
  }
}
