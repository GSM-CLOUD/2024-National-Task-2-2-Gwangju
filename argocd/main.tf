resource "helm_release" "argocd" {
  name = "argocd"
  chart = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  namespace = "argocd"
  create_namespace = true

  values = [
    <<-EOT
global:
  domain: ${data.kubernetes_service.nginx_ingress_controller.status[0].load_balancer[0].ingress[0].hostname}
configs:
    params:
        server.insecure: true
        server.rootpath: /argocd
    secret:
        argocdServerAdminPassword: "${bcrypt(var.password)}"

server:
    ingress:
        enabled: true
        ingressClassName: "nginx"
        path: /argocd
EOT
  ]

  skip_crds = false
}

resource "helm_release" "argo_rollout" {
  namespace = "argocd"
  create_namespace = true
  repository = "https://argoproj.github.io/argo-helm"

  name = "argo-rollouts"
  chart = "argo-rollouts"
  version = "2.31.1"

  depends_on = [helm_release.argocd]
}