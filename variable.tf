variable "region" {
  default = "ap-northeast-2"
}

variable "awscli_profile" {
  default = "default"
}

variable "prefix" {
  default = "gwangju"
}

variable "cluster_name" {
  default = "gwangju-eks-cluster"
}

variable "file_bucket_name" {
  default = "gwangju-file-bucket"
}

variable "alb_ingress_name" {
  default = "blue-green-ingress"
}

variable "alb_name" {
  default = "gwangju-blue-green-alb"
}

variable "app_namespace" {
  default = "app"
}

variable "argocd_password" {
  default = "password"
  sensitive = true
}