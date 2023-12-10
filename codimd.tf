resource "kubernetes_service" "codimd_service" {
  metadata {
    name      = "codimd-svc"
    namespace = "productivity-stack-srikanth-iyengar"
  }
  spec {
    type                        = "ClusterIP"
    publish_not_ready_addresses = true
    port {
      name        = "codimd-port"
      port        = "3000"
      target_port = "3000"
    }
    selector = {
      App = "codimd-sts"
    }
  }
}

resource "kubernetes_config_map" "codimd_entrypoint" {
  metadata {
    name      = "codimd-startscript"
    namespace = "productivity-stack-srikanth-iyengar"
    labels = {
      conf = "codimd"
    }
  }
  data = {
    "start.sh" = <<EOF
    #!/usr/bin/env bash

set -euo pipefail

npm install pg --save

if [[ "$#" -gt 0 ]]; then
    exec "$@"
    exit $?
fi

# check database and redis is ready
pcheck -env CMD_DB_URL

# run DB migrate
NEED_MIGRATE=`CMD_AUTO_MIGRATE:=true`

if [[ "$NEED_MIGRATE" = "true" ]] && [[ -f .sequelizerc ]] ; then
    npx sequelize db:migrate
fi

# start application
node app.js
EOF
  }
}

resource "kubernetes_stateful_set" "codimd_sts" {
  metadata {
    name      = "codimd-sts"
    namespace = "productivity-stack-srikanth-iyengar"
  }
  spec {
    service_name          = "codimd-svc"
    pod_management_policy = "OrderedReady"
    replicas              = 1
    selector {
      match_labels = {
        App = "codimd-sts"
      }
    }
    template {
      metadata {
        labels = {
          App = "codimd-sts"
        }
      }
      spec {
        security_context {
          fs_group = 1001
        }
        container {
          name  = "codimd-container"
          image = "hackmdio/hackmd"
          security_context {
            run_as_non_root            = true
            run_as_user                = 1001
            allow_privilege_escalation = false
          }
          volume_mount {
            name       = "datadir"
            mount_path = "/home/hackmd/app/public/uploads"
          }
          env {
            name  = "CMD_DB_URL"
            value = "mysql://root:${random_string.mysql_password.result}@mysql-service.productivity-stack-srikanth-iyengar.svc.cluster.local:3306/codimd"
          }
        }
      }
    }
    volume_claim_template {
      metadata {
        name      = "datadir"
        namespace = "productivity-stack-srikanth-iyengar"
      }
      spec {
        access_modes = ["ReadWriteOnce"]
        resources {
          requests = {
            storage = "1024Mi"
          }
        }
      }
    }
  }
}
