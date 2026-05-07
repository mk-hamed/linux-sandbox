resource "aws_route53_record" "linux_sandbox" {
  zone_id = data.aws_route53_zone.linux_sandbox.zone_id
  name    = "linuxsandbox.dev"
  type    = "A"

  alias {
    name                   = kubernetes_service_v1.linux_sandbox.status[0].load_balancer[0].ingress[0].hostname
    zone_id                = var.elb_zone_id
    evaluate_target_health = true
  }

  depends_on = [kubernetes_service_v1.linux_sandbox]
}

data "aws_route53_zone" "linux_sandbox" {
  name = "linuxsandbox.dev"
}