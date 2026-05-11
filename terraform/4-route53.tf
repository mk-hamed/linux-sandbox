
resource "aws_route53_record" "linux_sandbox" {
  zone_id = data.aws_route53_zone.linux_sandbox.zone_id
  name    = "linuxsandbox.dev"
  type    = "A"

  alias {
    name                   = data.kubernetes_service_v1.ingress-nginx-controller.status[0].load_balancer[0].ingress[0].hostname
    zone_id                = var.elb_zone_id
    evaluate_target_health = true
  }

  depends_on = [helm_release.ingress-nginx]
}

data "aws_route53_zone" "linux_sandbox" {
  name = "linuxsandbox.dev"
}

data "kubernetes_service_v1" "ingress-nginx-controller" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }

  depends_on = [helm_release.ingress-nginx]
}