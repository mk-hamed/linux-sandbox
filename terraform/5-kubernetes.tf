resource "kubernetes_namespace" "linux_sandbox" {
  metadata {
    name = "linux-sandbox"
  }

  depends_on = [module.eks]
}

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
      port        = 80
      target_port = 7681
    }

    port {
      name        = "https"
      protocol    = "TCP"
      port        = 443
      target_port = 7681
    }
  }

  depends_on = [module.eks]
}