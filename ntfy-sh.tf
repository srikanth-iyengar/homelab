resource "random_string" "ntfy_volume_id" {
  length  = 25
  special = false
  upper   = false
  numeric = false
}

resource "random_string" "oidc_passphrase" {
  length  = 30
  special = false
}

resource "kubernetes_deployment" "ntfy-deployment" {
  metadata {
    name = "ntfy-deployment"
    labels = {
      App = "ntfy-deployment"
    }
    namespace = "dev-tools-srikanth-iyengar"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        App = "ntfy-deployment"
      }
    }
    template {
      metadata {
        labels = {
          App = "ntfy-deployment"
        }
      }
      spec {
        container {
          image   = "binwiederhier/ntfy:latest"
          name    = "ntfy"
          command = ["ntfy", "serve"]
          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
          volume_mount {
            name       = random_string.ntfy_volume_id.result
            mount_path = "/var/cache/ntfy"
          }
        }
        volume {
          name = random_string.ntfy_volume_id.result
          persistent_volume_claim {
            claim_name = random_string.ntfy_volume_id.result
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "ntfy_service" {
  metadata {
    name      = "ntfy-service"
    namespace = "dev-tools-srikanth-iyengar"
  }
  spec {
    selector = {
      App = "ntfy-deployment"
    }
    port {
      name        = "ntfy-service"
      target_port = 80
      port        = 80
      protocol    = "TCP"
    }
  }
}


resource "kubernetes_persistent_volume_claim" "ntfy-pvc" {
  metadata {
    name      = random_string.ntfy_volume_id.result
    namespace = "dev-tools-srikanth-iyengar"
  }

  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "okteto-standard"

    resources {
      requests = {
        storage = "512Mi"
      }
    }
  }
}
