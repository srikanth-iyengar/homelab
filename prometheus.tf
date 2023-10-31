resource "kubernetes_service" "prometheus_service" {
  metadata {
    name      = "prometheus-svc"
    namespace = "essentials-srikanth-iyengar"
  }
  spec {
    type                        = "ClusterIP"
    publish_not_ready_addresses = true
    port {
      name        = "prometheus-port"
      port        = "9090"
      target_port = "9090"
    }
    selector = {
      App = "prometheus-sts"
    }
  }
}

resource "kubernetes_config_map" "prometheus_config" {
  metadata {
    name      = "prometheus-config"
    namespace = "essentials-srikanth-iyengar"
    labels = {
      conf = "prometheus"
    }
  }
  data = {
    "prometheus.yml"     = <<EOF
    # my global config
global:
  scrape_interval: 15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  # scrape_timeout is set to the global default (10s).

# Alertmanager configuration
alerting:
  alertmanagers:
    - static_configs:
        - targets:
          # - alertmanager:9093

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: "prometheus"

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
      - targets: ["localhost:9090"]
  - job_name: "dynamic_configs"
    file_sd_configs:
    - files:
      - '/opt/dynamic_config.yml'
      EOF
    "dynamic_config.yml" = <<EOF
- targets:
  - 'https://d2.srikanthk.tech'
  labels: ["key":"value"]
    EOF
  }
}
resource "kubernetes_stateful_set" "prometheus_sts" {
  metadata {
    name      = "prometheus-sts"
    namespace = "essentials-srikanth-iyengar"
  }
  spec {
    service_name          = "prometheus-svc"
    pod_management_policy = "OrderedReady"
    replicas              = 1
    selector {
      match_labels = {
        App = "prometheus-sts"
      }
    }
    template {
      metadata {
        labels = {
          App = "prometheus-sts"
        }
      }
      spec {
        security_context {
          fs_group = 1001
        }
        container {
          name  = "prometheus-container"
          image = "docker.io/bitnami/prometheus"
          #volume_mount {
          #  name       = "datadir"
          #  mount_path = "/opt/bitnami/prometheus/data"
          #}
          security_context {
            run_as_non_root            = true
            run_as_user                = 1001
            allow_privilege_escalation = false
          }
          volume_mount {
            name       = "config"
            mount_path = "/opt/bitnami/prometheus/conf/prometheus.yml"
            sub_path   = "prometheus.yml"
          }
          #          volume_mount {
          #            name       = "config"
          #            mount_path = "/opt/dynamic_config.yml"
          #            sub_path   = "dynamic_config.yml"
          #          }
        }
        volume {
          name = "config"
          config_map {
            name = "prometheus-config"
          }
        }
      }
    }
    volume_claim_template {
      metadata {
        name      = "datadir"
        namespace = "essentials-srikanth-iyengar"
      }
      spec {
        access_modes = ["ReadWriteOnce"]
        resources {
          requests = {
            storage = "512Mi"
          }
        }
      }
    }
  }
}
