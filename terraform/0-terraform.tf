terraform {
  required_version = ">= 1.5.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.28"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "3.1.1"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = var.project
      ManagedBy   = "Terraform"
      Environment = var.environment
    }
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
  }
}

provider "helm" {

  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    }
  }
}

resource "helm_release" "ingress-nginx" {
  name             = "ingress-nginx"
  namespace        = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  version          = "4.15.1"
  chart            = "ingress-nginx"
  create_namespace = true

  set = [
    {
      name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type",
      value = "nlb"
    }
  ]

  depends_on = [module.eks]
}

resource "helm_release" "cert-manager" {
  name = "cert-manager"
  namespace = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart = "cert-manager"
  create_namespace = true

  set = [ {
    name = "crds.enabled"
    value = "true"
  } ]

  depends_on = [ module.eks ]
}