resource "random_string" "keycloak_secret" {
  length = 20
}

resource "random_string" "keycloak_volume_id" {
  length  = 10
  special = false
  upper   = false
  numeric = false
}

resource "kubernetes_deployment" "keycloak_deployment" {
  metadata {
    name = "keycloak-deployment"
    labels = {
      App = "keycloak-deployment"
    }
    namespace = "essentials-srikanth-iyengar"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        App = "keycloak-deployment"
      }
    }
    template {
      metadata {
        labels = {
          App = "keycloak-deployment"
        }
      }
      spec {
        container {
          image = "quay.io/keycloak/keycloak:22.0.1"
          name  = "keycloak"
          args  = ["start-dev"]
          resources {
            limits = {
              cpu    = "1"
              memory = "2Gi"
            }
          }
          env {
            name  = "KC_PROXY"
            value = "edge"
          }
          env {
            name  = "KC_DB"
            value = "postgres"
          }
          env {
            name  = "KC_DB_URL"
            value = var.supabase_db_url
          }
          env {
            name  = "KC_DB_USERNAME"
            value = var.supabase_db_username
          }
          env {
            name  = "KC_DB_PASSWORD"
            value = var.supabase_db_password
          }
          env {
            name  = "KEYCLOAK_ADMIN"
            value = "admin"
          }
          env {
            name  = "KEYCLOAK_ADMIN_PASSWORD"
            value = random_string.keycloak_secret.result
          }
        }
      }
    }
  }
}


resource "kubernetes_service" "keycloak_service" {
  metadata {
    name      = "keycloak-service"
    namespace = "essentials-srikanth-iyengar"
  }
  spec {
    selector = {
      App = "keycloak-deployment"
    }
    port {
      name        = "keycloak-service"
      target_port = 8080
      port        = 8080
    }
  }

}
