resource "kubernetes_manifest" "app_namespace" {
  manifest = {
    apiVersion = "v1",
    kind = "Namespace",
    metadata = {
      name = "app"
    }
  }
}

resource "kubernetes_manifest" "app_deployment" {
  for_each = fileset("${path.module}/manifest", "app_*.yaml")

 manifest = yamldecode(
  replace(
    replace(
      replace(
        replace(
        file("${path.module}/manifest/${each.value}"),
        "$(NAMESPACE)", var.app_namespace),
        "$(ALB_INGRESS_NAME)", var.alb_ingress_name),
        "$(ALB_NAME)", var.alb_name),
        "$(ALB_DNS_NAME)", data.kubernetes_service.nginx_ingress_controller.status[0].load_balancer[0].ingress[0].hostname
    )
  )

  depends_on = [
    kubernetes_manifest.app_namespace
  ]
}