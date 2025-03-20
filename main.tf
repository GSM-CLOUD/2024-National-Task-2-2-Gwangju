module "vpc" {
  source = "./vpc"
  prefix = var.prefix
  region = var.region
  cluster_name = var.cluster_name
}

module "eks" {
  source = "./eks"
  cluster_name = var.cluster_name
  prefix = var.prefix
  vpc_id = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  
  depends_on = [ module.vpc ]
}


module "s3" {
  source = "./s3"
  prefix = var.prefix
  file_bucket_name = var.file_bucket_name

  depends_on = [ module.eks ]
}

module "ecr" {
  source = "./ecr"
  prefix = var.prefix

  depends_on = [ module.s3 ]
}

module "codecommit" {
  source = "./codecommit"
  prefix = var.prefix

  depends_on = [ module.ecr ]
}

module "bastion" {
  source = "./bastion"
  prefix = var.prefix
  vpc_id = module.vpc.vpc_id
  cluster_name = var.cluster_name
  ami_id = data.aws_ami.al2023_ami_amd.id
  public_subnets = module.vpc.public_subnets
  cluster_sg_id = module.eks.cluster_sg_id
  file_bucket_name = module.s3.file_bucket_name
  region = var.region
  account_id = data.aws_caller_identity.current.account_id
  primary_cluster_sg_id = module.eks.primary_cluster_sg_id
  ecr_app_name = module.ecr.ecr_app_name
  app_repo_name = module.codecommit.app_repo_name
  gitops_repo_name = module.codecommit.gitops_repo_name
  app_namespace = var.app_namespace
  rollout_app_name = var.rollout_app_name

  depends_on = [ module.codecommit ]
}

module "lb_controller" {
  source = "./lb_controller"
  prefix = var.prefix
  vpc_id = module.vpc.vpc_id
  eks_cluster_name = module.eks.cluster_name
  eks_oidc_provider_arn = module.eks.eks_oidc_provider_arn

  depends_on = [ module.bastion ]
}

module "nginx_ingress_controller" {
  source = "./nginx_ingress_controller"
  prefix = var.prefix
  oidc_provider_arn = module.eks.eks_oidc_provider_arn
  alb_sg_id = module.lb_controller.alb_sg_id

  depends_on = [ module.lb_controller ]
}
module "argocod" {
  source = "./argocd"
  password = var.argocd_password
  prefix = var.prefix

  depends_on = [ module.nginx_ingress_controller ]  
}

module "resources" {
  source = "./resources"
  app_namespace = var.app_namespace
  alb_name = var.alb_name
  alb_ingress_name = var.alb_ingress_name
  rollout_app_name = var.rollout_app_name
  account_id = data.aws_caller_identity.current.account_id
  region = var.region

  depends_on = [ module.argocod ]
}

module "codebuild" {
  source = "./codebuild"
  prefix = var.prefix
  app_repo_clone_url_http = module.codecommit.app_repo_clone_url_http

  depends_on = [ module.resources ]
}

module "codepipeline" {
  source = "./codepipline"
  prefix = var.prefix
  app_repo_name = module.codecommit.app_repo_name
  app_build_project_name = module.codebuild.app_build_project_name
  region = var.region
  account_id = data.aws_caller_identity.current.account_id

  depends_on = [ module.codebuild ]
}