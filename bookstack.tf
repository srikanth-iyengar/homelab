resource "random_string" "mysql_password" {
  length = 35
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

resource "kubernetes_deployment" "bookstack_deployment" {
  metadata {
    name      = "bookstack-deployment"
    namespace = "productivity-stack-srikanth-iyengar"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        App = "bookstack-deployment"
      }
    }
    template {
      metadata {
        labels = {
          App = "bookstack-deployment"
        }
      }
      spec {
        #        init_container {
        #          name              = "init-master"
        #          image             = "busybox"
        #          image_pull_policy = "Always"
        #
        #          command = ["sh", "-c", "chmod 777 /volumes/*"]
        #
        #          volume_mount {
        #            mount_path = "/volumes/${random_string.bookstack_volume.result}"
        #            name       = random_string.bookstack_volume.result
        #          }
        #        }
        #        init_container {
        #          name              = "init-volume-master"
        #          image             = "mysql:latest"
        #          image_pull_policy = "IfNotPresent"
        #
        #          command = ["sh", "-c", "echo initializing volume... && (cp -Rv /var/www/bookstack/. /init-volume-0 || true)"]
        #
        #          volume_mount {
        #            mount_path = "/init-volume-0"
        #            name       = random_string.bookstack_volume.result
        #            sub_path   = random_string.bookstack_volume.result
        #          }
        #        }
        container {
          image = "solidnerd/bookstack"
          name  = "bookstack"
          #          volume_mount {
          #            name       = random_string.bookstack_volume.result
          #            mount_path = "/var/www/bookstack"
          #          }
          resources {
            limits = {
              cpu    = "1"
              memory = "1024Mi"
            }
          }
          env {
            name  = "DB_HOST"
            value = "mysql-service.productivity-stack-srikanth-iyengar.svc.cluster.local:3306"
          }
          env {
            name  = "DB_DATABASE"
            value = "bookstack-db"
          }
          env {
            name  = "DB_USERNAME"
            value = "root"
          }
          env {
            name  = "DB_PASSWORD"
            value = random_string.mysql_password.result
          }
          env {
            name  = "APP_URL"
            value = "https://bookstack.srikanthk.tech"
          }
          env {
            name  = "APP_KEY"
            value = "https://bookstack.srikanthk.tech"
          }
        }
        #        volume {
        #          name = random_string.bookstack_volume.result
        #          persistent_volume_claim {
        #            claim_name = random_string.bookstack_volume.result
        #          }
        #        }
      }
    }
  }
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

resource "kubernetes_service" "bookstack_service" {
    metadata {
        name = "bookstack-service"
        namespace = "productivity-stack-srikanth-iyengar"
    }

  spec {
    selector = {
      App = "bookstack-deployment"
    }
    port {
      name        = "bookstack-service"
      target_port = 8080
      port        = 8080
      protocol    = "TCP"
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

#resource "kubernetes_persistent_volume_claim" "bookstack_storage_pvc" {
#  metadata {
#    name      = random_string.bookstack_volume.result
#    namespace = "productivity-stack-srikanth-iyengar"
#  }
#
#  spec {
#    access_modes = ["ReadWriteOnce"]
#    storage_class_name = "okteto-standard"
#    resources {
#      requests = {
#        storage = "1512Mi"
#      }
#    }
#  }
#}
