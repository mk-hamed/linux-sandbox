data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  name   = "linux-sandbox"
  region = "eu-east-1"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {}
}

variable "region" {
  type        = string
  description = "The AWS region where resources will be deployed."
  default     = "us-east-1"
}

variable "project" {
  type        = string
  description = "Project name for resource naming and tagging."
  default     = "linux-sandbox"
}

variable "environment" {
  type        = string
  description = "Environment name."
  default     = "dev"
}

variable "tags" {
  type = map(string)
  default = {
    terraform  = "true"
    kubernetes = "linux-sandbox"
  }
  description = "Prefix for VPC resource names."
}

#######################
#### VPC variables ####
#######################

variable "vpc_name" {
  type    = string
  default = "linux-sandbox-vpc"
}

variable "cidr_block" {
  type        = string
  description = "CIDR block for the VPC network."
  default     = "10.10.0.0/16"
}

#######################
#### EKS variables ####
#######################

variable "cluster_name" {
  type        = string
  description = "Value for EKS cluster names."
  default     = "linux-sandbox"
}

variable "eks_version" {
  type        = string
  description = "EKS version."
  default     = "1.34"
}