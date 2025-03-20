module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_version = "1.31"
  cluster_name = var.cluster_name

  cluster_endpoint_public_access = true

  vpc_id = var.vpc_id
  subnet_ids = var.private_subnets
  control_plane_subnet_ids = var.private_subnets

  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    worker_node = {
        vpc_security_group_ids = [module.eks.cluster_security_group_id, module.eks.node_security_group_id]
        instance_types = ["t3.medium"]
        ami_type = "AL2023_x86_64_STANDARD"
        desired_size = 2
        min_size = 2
        max_size = 4
    }
  }

  cluster_addons = {
    coredns = {}
    eks-pod-identity-agent = {}
    kube-proxy = {}
    vpc-cni = {}
  }
}