data "kubernetes_service" "linux_sandbox" {
    metadata {
      name = "linux-sandbox"
      namespace = "linux-sandbox"
    }
}

resource "aws_route53_record" "linux_sandbox" {
    zone_id = data.aws_route53_zone.linux_sandbox.zone_id
    name = "linuxsandbox.dev"
    type = "A"

    alias {
        name = data.kubernetes_service.linux_sandbox[0].load_balancer[0].ingress[0].hostname
        zone_id = var.nlb_zone_id
        evaluate_target_health = true
    }
}

data "aws_route53_zone" "linux_sandbox" {
    name = "linuxsandbox.dev"
}