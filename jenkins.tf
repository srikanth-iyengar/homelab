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
    namespace = "automation-srikanth-iyengar"
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
        container {
          image = "jenkins/jenkins:lts"
          name  = "jenkins"
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
          volume_mount {
            name       = random_string.volume_id.result
            mount_path = "/var/jenkins_home/workspace"
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
    namespace = "automation-srikanth-iyengar"
  }
  spec {
    selector = {
      App = "jenkins-deployment"
    }
    type = "LoadBalancer"
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
    namespace = "automation-srikanth-iyengar"
  }

  spec {
    storage_class_name = "csi-okteto"
    access_modes       = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "3.5Gi"
      }
    }
  }
}
