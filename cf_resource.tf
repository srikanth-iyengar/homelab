resource "random_id" "tunnel_secret" {
  byte_length = 35
}

resource "cloudflare_tunnel" "auto_tunnel" {
  account_id = var.cloudflare_account_id
  name       = "Terraform OKTETO tunnel"
  secret     = random_id.tunnel_secret.b64_std
}

resource "cloudflare_record" "jenkins" {
  zone_id = var.cloudflare_zone_id
  name    = "jenkins"
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
      service  = "http://jenkins-service.automation-srikanth-iyengar.svc.cluster.local:8080"
    }
    ingress_rule {
      service = "http_status:404"
    }
  }
}

resource "cloudflare_access_application" "jenkins" {
  zone_id          = var.cloudflare_zone_id
  name             = "Access application for jenkins.${var.cloudflare_zone}"
  domain           = "jenkins.${var.cloudflare_zone}"
  session_duration = "1h"
}
