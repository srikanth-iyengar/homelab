resource "random_string" "grafana_volume_id" {
  length  = 30
  special = false
  upper   = false
  numeric = false
}

resource "kubernetes_deployment" "grafana_deployment" {
  metadata {
    name      = "grafana-deployment"
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
        init_container {
          name              = "init-master"
          image             = "busybox"
          image_pull_policy = "Always"

          command = ["sh", "-c", "chmod 777 /volumes/*"]

          volume_mount {
            mount_path = "/volumes/${random_string.grafana_volume_id.result}"
            name       = random_string.grafana_volume_id.result
          }
        }

        init_container {
          name              = "init-volume-grafana"
          image             = "grafana/grafana"
          image_pull_policy = "IfNotPresent"

          command = ["sh", "-c", "echo initializing volume... && (cp -Rv /var/lib/grafana/. /init-volume-0 || true)"]

          volume_mount {
            mount_path = "/init-volume-0"
            name       = random_string.grafana_volume_id.result
            sub_path   = random_string.grafana_volume_id.result
          }
        }
        container {
          image = "grafana/grafana"
          name  = "grafana-deployment"
          resources {
            limits = {
              cpu    = "1"
              memory = "1024Mi"
            }
          }
          volume_mount {
            name       = random_string.grafana_volume_id.result
            mount_path = "/var/lib/grafana"
            sub_path   = random_string.grafana_volume_id.result
          }
        }
        volume {
          name = random_string.grafana_volume_id.result
          persistent_volume_claim {
            claim_name = random_string.grafana_volume_id.result
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "grafana_service" {
  metadata {
    name      = "grafana-service"
    namespace = "essentials-srikanth-iyengar"
  }
  spec {
    selector = {
      App = "grafana-deployment"
    }
    port {
      name        = "grafana-service"
      port        = 3000
      target_port = 3000
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_persistent_volume_claim" "grafana_pvc" {
  metadata {
    name      = random_string.grafana_volume_id.result
    namespace = "essentials-srikanth-iyengar"
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1.0Gi"
      }
    }
  }
}
