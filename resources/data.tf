data "kubernetes_service" "nginx_ingress_controller" {
  metadata {
    name = "ingress-nginx"
    namespace = "ingress-nginx"
  }
}