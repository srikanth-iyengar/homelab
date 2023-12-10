resource "random_string" "mysql_password" {
  length  = 35
  special = false
  upper   = false
  numeric = false
}

resource "random_string" "mysql_volume_id" {
  length  = 20
  special = false
  upper   = false
  numeric = false
}

resource "random_string" "bookstack_volume" {
  length  = 25
  special = false
  upper   = false
  numeric = false
}

resource "kubernetes_deployment" "mysql_deployment" {
  metadata {
    name      = "mysql-deployment"
    namespace = "productivity-stack-srikanth-iyengar"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        App = "mysql-deployment"
      }
    }
    template {
      metadata {
        labels = {
          App = "mysql-deployment"
        }
      }
      spec {
        init_container {
          name              = "init-master"
          image             = "busybox"
          image_pull_policy = "Always"

          command = ["sh", "-c", "chmod 777 /volumes/*"]

          volume_mount {
            mount_path = "/volumes/${random_string.bookstack_volume.result}"
            name       = random_string.mysql_volume_id.result
          }
        }

        init_container {
          name              = "init-volume-master"
          image             = "mysql:latest"
          image_pull_policy = "IfNotPresent"

          command = ["sh", "-c", "echo initializing volume... && (cp -Rv /var/lib/mysql/. /init-volume-0 || true)"]

          volume_mount {
            mount_path = "/init-volume-0"
            name       = random_string.mysql_volume_id.result
            sub_path   = random_string.mysql_volume_id.result
          }
        }
        container {
          name  = "mysql-deployment"
          image = "mariadb:latest"
          volume_mount {
            name       = random_string.mysql_volume_id.result
            mount_path = "/var/lib/mysql"
          }
          env {
            name  = "MYSQL_ROOT_PASSWORD"
            value = random_string.mysql_password.result
          }
        }
        volume {
          name = random_string.mysql_volume_id.result
          persistent_volume_claim {
            claim_name = random_string.mysql_volume_id.result
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "mysql_service" {
  metadata {
    name      = "mysql-service"
    namespace = "productivity-stack-srikanth-iyengar"
  }

  spec {
    selector = {
      App = "mysql-deployment"
    }
    port {
      name        = "mysql-service"
      target_port = 3306
      port        = 3306
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_persistent_volume_claim" "bookstack_pvc" {
  metadata {
    name      = random_string.mysql_volume_id.result
    namespace = "productivity-stack-srikanth-iyengar"
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}
