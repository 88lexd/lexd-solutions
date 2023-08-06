resource "cloudflare_ruleset" "waf" {
  zone_id     = cloudflare_zone.lexdsolutions.id
  name        = "custom-waf-rules"
  description = "Custom WAF rules"
  kind        = "zone"
  phase       = "http_request_firewall_custom"

  # The order is as specified in this resource (top down)
  # Free plan can create up to 5 custom rules
  rules {
    description = "Allow LinkedInBot"
    expression  = "(http.user_agent contains \"LinkedInBot\")"
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
    description = "Known Bots Challenge"
    expression  = "(cf.client.bot)"
    action      = "managed_challenge"
    enabled     = true
  }

  rules {
    description = "wp-login.php Challenge"
    expression  = "(http.request.uri.path eq \"/wp-login.php\")"
    action      = "challenge"
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
