resource "kubernetes_deployment" "tunnel" {
  metadata {
    name = "cf-tunnel"
    labels = {
      App = "cf-tunnel"
    }
    namespace = "srikanth-iyengar"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        App = "cf-tunnel"
      }
    }
    template {
      metadata {
        labels = {
          App = "cf-tunnel"
        }
      }
      spec {
        container {
          image   = "cloudflare/cloudflared"
          name    = "tunnel"
          command = ["cloudflared", "tunnel", "--no-autoupdate", "run", "--token", cloudflare_tunnel.auto_tunnel.tunnel_token]
          resources {
            limits = {
              cpu    = "1"
              memory = "1024Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}

