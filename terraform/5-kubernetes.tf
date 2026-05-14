resource "kubernetes_namespace" "linux_sandbox" {
  metadata {
    name = "linux-sandbox"
  }

  depends_on = [module.eks]
}

#################################
#### TTYD Terminal Manifests ####
#################################

resource "kubernetes_deployment_v1" "linux_sandbox" {
  metadata {
    name      = "linux-sandbox"
    namespace = kubernetes_namespace.linux_sandbox.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "linux-sandbox"
      }
    }

    template {
      metadata {
        labels = {
          app = "linux-sandbox"
        }
      }

      spec {
        container {
          name  = "linux-sandbox"
          image = "705738638798.dkr.ecr.us-east-1.amazonaws.com/linux-sandbox:latest"

          port {
            container_port = 7681
          }
        }
      }
    }
  }

  depends_on = [module.eks]
}

resource "kubernetes_service_v1" "linux_sandbox" {
  metadata {
    name      = "linux-sandbox"
    namespace = kubernetes_deployment_v1.linux_sandbox.metadata[0].name
  }

  spec {
    selector = {
      app = "linux-sandbox"
    }

    type = "ClusterIP"

    port {
      name        = "http"
      protocol    = "TCP"
      port        = 7681
      target_port = 7681
    }
  }

  depends_on = [module.eks]
}

################################
#### Landing Page Manifests ####
################################

resource "kubernetes_deployment_v1" "linux_sandbox_landing" {
  metadata {
    name      = "linux-sandbox-landing"
    namespace = kubernetes_namespace.linux_sandbox.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "linux-sandbox-landing"
      }
    }

    template {
      metadata {
        labels = {
          app = "linux-sandbox-landing"
        }
      }

      spec {
        container {
          name  = "linux-sandbox-landing"
          image = "705738638798.dkr.ecr.us-east-1.amazonaws.com/linux-sandbox-landing:latest"

          port {
            container_port = 80
          }
        }
      }
    }
  }

  depends_on = [module.eks]
}

resource "kubernetes_service_v1" "linux_sandbox_landing" {
  metadata {
    name      = "linux-sandbox-landing"
    namespace = kubernetes_namespace.linux_sandbox.metadata[0].name
  }

  spec {
    selector = {
      app = "linux-sandbox-landing"
    }

    type = "ClusterIP"

    port {
      name        = "http"
      protocol    = "TCP"
      port        = 80
      target_port = 80
    }
  }

  depends_on = [module.eks, helm_release.ingress-nginx]
}

######################################
#### Ingress Controller Manifests ####
######################################

resource "kubernetes_ingress_v1" "linux_sandbox_ingress" {
  metadata {
    name      = "linux-sandbox-ingress"
    namespace = kubernetes_namespace.linux_sandbox.metadata[0].name

    annotations = {
      "nginx.ingress.kubernetes.io/ssl-redirect"              = "true"
      "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
      "nginx.ingress.kubernetes.io/rewrite-target" = "/$2"
    }
  }

  spec {
    ingress_class_name = "nginx"
    tls {
      secret_name = "linuxsandbox-tls"
      hosts = [ "linuxsandbox.dev" ]
    }
    rule {
      host = "linuxsandbox.dev"
      http {
        # Routing to ttyd terminal 
        path {
          path      = "/terminal(/|$)(.*)"
          path_type = "ImplementationSpecific"
          backend {
            service {
              name = kubernetes_service_v1.linux_sandbox.metadata[0].name
              port {
                number = 7681
              }
            }
          }
        }
        # Routing to landing page
        path {
          path      = "/()(.*)"
          path_type = "ImplementationSpecific"
          backend {
            service {
              name = kubernetes_service_v1.linux_sandbox_landing.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_manifest" "cluster_issuer" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"

    metadata = {
      name = "letsencrypt-prod"
    }

    spec = {
      acme = {
        email  = "hamedk.moh@gmail.com"
        server = "https://acme-v02.api.letsencrypt.org/directory"

        privateKeySecretRef = {
          name = "letsencrypt-prod-key"
        }

        solvers = [{
          http01 = {
            ingress = {
              class = "nginx"
            }
          }
        }]
      }
    }
  }

  depends_on = [helm_release.cert-manager]
}
