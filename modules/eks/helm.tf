# added kubeconfig
resource "null_resource" "kubeconfig" {
  depends_on = [aws_eks_node_group.main]
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${var.env}"
  }
}

resource "helm_release" "nginx_ingress" {
  depends_on       = [null_resource.kubeconfig]
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "tools"
  create_namespace = true
  values           = [file("${path.module}/helm-values/ingress.yml")]
}
