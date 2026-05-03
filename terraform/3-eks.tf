####################
#### EKS Module ####
####################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~>21.0"

  name               = var.cluster_name
  kubernetes_version = var.eks_version

  addons = {
    coredns = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy = {}
    vpc-cni = {
      before_compute = true
    }
  }

  endpoint_private_access = true
  endpoint_public_access  = true

  vpc_id                   = module.eks-vpc.vpc_id
  subnet_ids               = module.eks-vpc.private_subnets
  control_plane_subnet_ids = concat(module.eks-vpc.public_subnets, module.eks-vpc.private_subnets)

  authentication_mode                      = "API"
  enable_cluster_creator_admin_permissions = true

  dataplane_wait_duration = "40s"

  # EKS Managed Node Group(s)
  create_node_security_group                   = true
  node_security_group_enable_recommended_rules = true
  node_security_group_description              = "EKS node group security group - used by nodes to communicate with the cluster API Server"

  node_security_group_use_name_prefix = true

  eks_managed_node_groups = {
    group1 = {
      name           = "linux-sandbox-group"
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t3.micro"]
      capacity_type  = "SPOT"
      min_size       = 1
      max_size       = 3
      desired_size   = 2
    }
  }

  tags = var.tags
}