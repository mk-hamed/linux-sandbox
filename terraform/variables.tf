locals {
  name   = "linux-sandbox-cluster"
  region = "us-east-1"

  vpc_cidr = "10.0.0.0/16"
  azs      = ["us-east-1a", "us-east-1b"]

  tags = {
    Example    = local.name
    GithubRepo = "linux-sandbox"
  }
}

variable "region" {
  description = "The AWS region where resources will be deployed"
  type        = string
  default     = "us-east-1"
}