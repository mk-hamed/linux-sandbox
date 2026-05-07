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

    annotations = {
      # attach ACM SSL certification to our classic load balancer (CLB) service
      "service.beta.kubernetes.io/aws-load-balancer-ssl-cert" = "arn:aws:acm:us-east-1:705738638798:certificate/29234ef0-e457-4334-9f8d-5b954c71bd4b"
      # public port 443 configuration for CLB
      "service.beta.kubernetes.io/aws-load-balancer-ssl-ports" = "443"
      # idle timeout 
      "service.beta.kubernetes.io/aws-load-balancer-connection-idle-timeout" = "3600"
    }
  }

  spec {
    selector = {
      app = "linux-sandbox"
    }

    type = "LoadBalancer"

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