resource "kubernetes_deployment" "grafana_deployment" {
    metadata {
        name = "grafana-deployment"
        namespace = "essentials-srikanth-iyengar"
    }

  spec {
    replicas = 1
    selector {
      match_labels = {
        App = "grafana-deployment"
      }
    }
    template {
      metadata {
        labels = {
          App = "grafana-deployment"
        }
      }
      spec {
        container {
          image   = "grafana/grafana"
          name    = "grafana-deployment"
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

resource "kubernetes_service" "grafana_service" {
    metadata {
        name = "grafana-service"
        namespace = "essentials-srikanth-iyengar"
    }
    spec {
        selector = {
            App = "grafana-deployment"
        }
        port {
            name = "grafana-service"
            port = 3000
            target_port = 3000
            protocol = "TCP"
        }
    }
}
