data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.vegetables_cluster_IaC.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.vegetables_cluster_IaC.master_auth[0].cluster_ca_certificate)

}

resource "kubernetes_deployment_v1" "deploy_vegetables_IaC" {
  metadata {
    name = "vegetable-deployment-iac"
  }

  spec {
    selector {
      match_labels = {
        app = "classifier-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "classifier-app"
        }
      }

      spec {
        container {
          image = "${var.region}-docker.pkg.dev/${var.project_name}/model-deploy/vegetables:v1"
          name  = "classifier-app-container"

          port {
            container_port = 8080
            name           = "vegetables-svc"
          }

          security_context {
            allow_privilege_escalation = false
            privileged                 = false
            read_only_root_filesystem  = false

            capabilities {
              add  = []
              drop = ["NET_RAW"]
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = "vegetables-svc"

              http_header {
                name  = "X-Custom-Header"
                value = "Awesome"
              }
            }

            initial_delay_seconds = 3
            period_seconds        = 3
          }
        }

        security_context {
          run_as_non_root = true

          seccomp_profile {
            type = "RuntimeDefault"
          }
        }

        # Toleration is currently required to prevent perpetual diff:
        # https://github.com/hashicorp/terraform-provider-kubernetes/pull/2380
        toleration {
          effect   = "NoSchedule"
          key      = "kubernetes.io/arch"
          operator = "Equal"
          value    = "amd64"
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "service_vegetables_IaC" {
  metadata {
    name = "vegetables-classifier-app-loadbalancer"
  }

  spec {
    selector = {
      app = kubernetes_deployment_v1.deploy_vegetables_IaC.spec[0].selector[0].match_labels.app
    }

    # ip_family_policy = "RequireDualStack"

    port {
      port        = 80
      target_port = kubernetes_deployment_v1.deploy_vegetables_IaC.spec[0].template[0].spec[0].container[0].port[0].name
    }

    type = "LoadBalancer"
  }

  depends_on = [time_sleep.wait_service_cleanup]
}

# Provide time for Service cleanup
resource "time_sleep" "wait_service_cleanup" {
  depends_on = [google_container_cluster.vegetables_cluster_IaC]

  destroy_duration = "180s"
}
