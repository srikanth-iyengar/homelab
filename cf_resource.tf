resource "random_id" "tunnel_secret" {
  byte_length = 35
}

resource "cloudflare_tunnel" "auto_tunnel" {
  account_id = var.cloudflare_account_id
  name       = "Okteto tunnel"
  secret     = random_id.tunnel_secret.b64_std
}

resource "cloudflare_record" "ntfy" {
  zone_id = var.cloudflare_zone_id
  name    = "ntfy"
  value   = cloudflare_tunnel.auto_tunnel.cname
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_record" "jenkins" {
  zone_id = var.cloudflare_zone_id
  name    = "jenkins"
  value   = cloudflare_tunnel.auto_tunnel.cname
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_record" "keycloak" {
  zone_id = var.cloudflare_zone_id
  name    = "keycloak"
  value   = cloudflare_tunnel.auto_tunnel.cname
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_record" "grafana" {
  zone_id = var.cloudflare_zone_id
  name    = "grafana"
  value   = cloudflare_tunnel.auto_tunnel.cname
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_record" "bookstack" {
  zone_id = var.cloudflare_zone_id
  name    = "bookstack"
  value   = cloudflare_tunnel.auto_tunnel.cname
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_record" "firefly" {
  zone_id = var.cloudflare_zone_id
  name    = "firefly"
  value   = cloudflare_tunnel.auto_tunnel.cname
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_tunnel_config" "auto_tunnel" {
  tunnel_id  = cloudflare_tunnel.auto_tunnel.id
  account_id = var.cloudflare_account_id
  config {
    ingress_rule {
      hostname = cloudflare_record.jenkins.hostname
      service  = "http://jenkins-service.dev-tools-srikanth-iyengar.svc.cluster.local:8080"
    }
    ingress_rule {
      hostname = cloudflare_record.ntfy.hostname
      service  = "http://ntfy-service.dev-tools-srikanth-iyengar.svc.cluster.local"
    }
    ingress_rule {
      hostname = cloudflare_record.keycloak.hostname
      service  = "http://keycloak-service.essentials-srikanth-iyengar.svc.cluster.local:8080"
    }
    ingress_rule {
      hostname = cloudflare_record.grafana.hostname
      service  = "http://grafana-service.essentials-srikanth-iyengar.svc.cluster.local:3000"
    }
    ingress_rule {
      hostname = cloudflare_record.bookstack.hostname
      service  = "http://bookstack-service.productivity-stack-srikanth-iyengar.svc.cluster.local:8080"
    }
    ingress_rule {
      hostname = cloudflare_record.firefly.hostname
      service  = "http://firefly-service.productivity-stack-srikanth-iyengar.svc.cluster.local:8080"
    }
    ingress_rule {
      service = "http_status:404"
    }
  }
}
