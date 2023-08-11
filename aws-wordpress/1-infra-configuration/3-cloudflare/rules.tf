resource "cloudflare_ruleset" "waf" {
  zone_id     = cloudflare_zone.lexdsolutions.id
  name        = "custom-waf-rules"
  description = "Custom WAF rules"
  kind        = "zone"
  phase       = "http_request_firewall_custom"

  # The order is as specified in this resource (top down)
  # Free plan can create up to 5 custom rules
  rules {
    description = "Restricted Page Challenge"
    expression  = "(http.request.uri.path eq \"/wp-login.php\") or (http.request.uri.path eq \"/xmlrpc.php\")"
    action      = "challenge"
    enabled     = true
  }

  rules {
    description = "Allow Countries"
    expression  = "(ip.geoip.country eq \"AU\")"
    action      = "skip"
    action_parameters {
      ruleset = "current"
    }
    logging {
      enabled = true
    }
    enabled = true
  }

  rules {
    description = "Bad Bots Challenge"
    expression  = "(not cf.client.bot)"
    action      = "managed_challenge"
    enabled     = true
  }

  rules {
    description = "Test challenge path"
    expression  = "(http.request.uri.path eq \"/waf-test\")"
    action      = "challenge"
    enabled     = true
  }
}

resource "cloudflare_ruleset" "www" {
  zone_id     = cloudflare_zone.lexdsolutions.id
  name        = "redirect-www"
  description = "Redirect rule"
  kind        = "zone"
  phase       = "http_request_dynamic_redirect"

  rules {
    description = "Redirect www."
    expression  = "(starts_with(http.host, \"www.\"))"
    action      = "redirect"
    action_parameters {
      from_value {
        status_code = 301
        target_url {
          value = "https://lexdsolutions.com"
        }
        preserve_query_string = true
      }
    }
    enabled = true
  }
}
