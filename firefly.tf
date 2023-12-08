resource "random_string" "firefly_app_key" {
  length  = 32
  special = false
}

resource "kubernetes_deployment" "firefly_iii_depl" {
  metadata {
    name = "firefly-deployment"
    labels = {
      App = "firefly-deployment"
    }
    namespace = "productivity-stack-srikanth-iyengar"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        App = "firefly-deployment"
      }
    }
    template {
      metadata {
        labels = {
          App = "firefly-deployment"
        }
      }
      spec {
        container {
          image = "fireflyiii/core:latest"
          name  = "fireflyiii-container"
          resources {
            limits = {
              cpu    = "1"
              memory = "1Gi"
            }
          }
          env {
            name  = "APP_KEY"
            value = random_string.firefly_app_key.result
          }
          env {
            name  = "DB_HOST"
            value = var.supabase_db_host
          }
          env {
            name  = "DB_PORT"
            value = "5432"
          }
          env {
            name  = "DB_CONNECTION"
            value = "pgsql"
          }
          env {
            name  = "DB_DATABASE"
            value = "firefly"
          }
          env {
            name  = "DB_USERNAME"
            value = var.supabase_db_username
          }
          env {
            name  = "DB_PASSWORD"
            value = var.supabase_db_password
          }
          env {
            name  = "APP_URL"
            value = "https://firefly.srikanthk.in"
          }
          env {
            name  = "TRUSTED_PROXIES"
            value = "*"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "firefly_service" {
  metadata {
    name      = "firefly-service"
    namespace = "productivity-stack-srikanth-iyengar"
  }

  spec {
    selector = {
      App = "firefly-deployment"
    }
    port {
      name        = "firefly-port"
      target_port = "8080"
      port        = "8080"
      protocol    = "TCP"
    }
  }
}
