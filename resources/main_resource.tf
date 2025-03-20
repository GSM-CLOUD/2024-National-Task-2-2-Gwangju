resource "kubernetes_manifest" "app_namespace" {
  manifest = {
    apiVersion = "v1",
    kind = "Namespace",
    metadata = {
      name = "app"
    }
  }
}

resource "kubernetes_manifest" "app_rollout" {
  for_each = fileset("${path.module}/manifest", "rollout.yaml")

  manifest = yamldecode(
    replace(
      replace(
        replace(
          replace(
      file("${path.module}/manifest/${each.value}"),
      "$(ROLLOUT_APP_NAME)", var.rollout_app_name),
      "$(NAMESPACE)", var.app_namespace),
      "$(REGION)", var.region),
      "$(ACCOUNT_ID)", var.account_id
    )
  )

  depends_on = [
    kubernetes_manifest.app_namespace
  ]
}

resource "kubernetes_manifest" "app_service" {
  for_each = fileset("${path.module}/manifest", "service*.yaml")

  manifest = yamldecode(
    replace(
      replace(
        replace(
          replace(
      file("${path.module}/manifest/${each.value}"),
      "$(ROLLOUT_APP_NAME)", var.rollout_app_name),
      "$(NAMESPACE)", var.app_namespace),
      "$(REGION)", var.region),
      "$(ACCOUNT_ID)", var.account_id
    )
  )

  depends_on = [
    kubernetes_manifest.app_rollout
  ]
}

resource "kubernetes_manifest" "app_ingress" {
  for_each = fileset("${path.module}/manifest", "ingress.yaml")

  manifest = yamldecode(
    replace(
      replace(
        replace(
          file("${path.module}/manifest/${each.value}"),
          "$(ALB_INGRESS_NAME)", var.alb_ingress_name),
          "$(NAMESPACE)", var.app_namespace),
          "$(ALB_DNS_NAME)", "gwangju-blue-green-alb-ef2826b9bb6b5a1a.elb.ap-northeast-2.amazonaws.com"
    )
  )

  depends_on = [
    kubernetes_manifest.app_service
  ]
}