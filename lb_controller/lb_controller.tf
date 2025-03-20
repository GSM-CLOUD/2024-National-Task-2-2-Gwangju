resource "helm_release" "aws-lb-controller" {
  namespace = "kube-system"
  name = "aws-lb-controller"
  repository = "https://aws.github.io/eks-charts"
  chart = "aws-load-balancer-controller"
  wait = true

  set {
    name = "clusterName"
    value = var.eks_cluster_name
  }

  set {
    name = "serviceAccount.create"
    value = "true"
  }

  set {
    name = "serviceAccount.name"
    value = "aws-lb-controller-sa"
  }

  set {
    name = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.aws-lb-controller-irsa-role.iam_role_arn
  }

  set {
    name = "replicaCount"
    value = 1
  }

  depends_on = [ module.aws-lb-controller-irsa-role ]
}
