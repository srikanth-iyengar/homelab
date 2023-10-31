resource "kubernetes_service" "sonar_svc" {
  metadata {
    name      = "sonar-service"
    namespace = "dev-tools-srikanth-iyengar"
    labels = {
      App = "sonarqube"
    }
  }
  spec {
    type                        = "ClusterIP"
    cluster_ip                  = "None"
    publish_not_ready_addresses = true
    port {
      name        = "sonar-expose"
      port        = 9000
      target_port = 9000
    }
    selector = {
      App = "sonarqube"
    }
  }
}

resource "kubernetes_stateful_set_v1" "sonarqube_deployment" {
  metadata {
    namespace = "dev-tools-srikanth-iyengar"
    name      = "sonarqube"
  }
  spec {
    service_name = "sonar-service"
    replicas     = 1
    selector {
      match_labels = {
        App = "sonarqube"
      }
    }
    template {
      metadata {
        labels = {
          App = "sonarqube"
        }
      }
      spec {
        security_context {
          fs_group = "1001"
        }
        container {
          name  = "sonarqube"
          image = "sonarqube"
          volume_mount {
            name       = "datadir"
            mount_path = "/opt/sonarqube/data"
            sub_path   = ""
          }
        }
      }
    }
    volume_claim_template {
      metadata {
        name = "datadir"
      }
      spec {
        access_modes = [
          "ReadWriteOnce"
        ]
        resources {
          requests = {
            storage = "2Gi"
          }
        }
      }
    }
  }
}
