resource "random_string" "volume_id" {
  length  = 10
  special = false
  upper   = false
  numeric = false
}

resource "kubernetes_deployment" "jenkins" {
  metadata {
    name = "jenkins-deployment"
    labels = {
      App = "jenkins-deployment"
    }
    namespace = "dev-tools-srikanth-iyengar"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        App = "jenkins-deployment"
      }
    }
    template {
      metadata {
        labels = {
          App = "jenkins-deployment"
        }
      }
      spec {
        init_container {
          name              = "init-master"
          image             = "busybox"
          image_pull_policy = "Always"

          command = ["sh", "-c", "chmod 777 /volumes/*"]

          volume_mount {
            mount_path = "/volumes/${random_string.volume_id.result}"
            name       = random_string.volume_id.result
          }
        }

        init_container {
          name              = "init-volume-master"
          image             = "jenkins/jenkins:lts"
          image_pull_policy = "IfNotPresent"

          command = ["sh", "-c", "echo initializing volume... && (cp -Rv /var/jenkins_home/. /init-volume-0 || true)"]

          volume_mount {
            mount_path = "/init-volume-0"
            name       = random_string.volume_id.result
            sub_path   = random_string.volume_id.result
          }
        }
        container {
          image = "jenkins/jenkins:lts"
          name  = "jenkins"
          resources {
            limits = {
              cpu    = "1"
              memory = "3.0Gi"
            }
          }
          volume_mount {
            name       = random_string.volume_id.result
            mount_path = "/var/jenkins_home"
            sub_path   = random_string.volume_id.result
          }
        }
        volume {
          name = random_string.volume_id.result
          persistent_volume_claim {
            claim_name = random_string.volume_id.result
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "jenkins-service" {
  metadata {
    name      = "jenkins-service"
    namespace = "dev-tools-srikanth-iyengar"
  }
  spec {
    selector = {
      App = "jenkins-deployment"
    }
    port {
      name        = "jenkins-service"
      target_port = 8080
      port        = 8080
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_persistent_volume_claim" "jenkins-pvc" {
  metadata {
    name      = random_string.volume_id.result
    namespace = "dev-tools-srikanth-iyengar"
  }

  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "okteto-standard"

    resources {
      requests = {
        storage = "1.0Gi"
      }
    }
  }
}
