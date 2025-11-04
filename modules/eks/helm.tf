# Added kubeconfig
resource "null_resource" "kubeconfig" {
  depends_on = [aws_eks_node_group.main]
  triggers = {
    always = timestamp()
  }
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${var.env}"
  }
}

#
resource "helm_release" "nginx_ingress" {
  depends_on       = [null_resource.kubeconfig]
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "tools"
  create_namespace = true
  values           = [file("${path.module}/helm-values/ingress.yml")]
}

# download external dns to automate dns creation
resource "helm_release" "external-dns" {
  depends_on       = [null_resource.kubeconfig]
  name             = "external-dns"
  repository       = "https://kubernetes-sigs.github.io/external-dns"
  chart            = "external-dns"
  namespace        = "tools"
  create_namespace = true
}

# Argo CD helm is used to install and manage Argo CD
resource "helm_release" "argocd" {
  depends_on       = [null_resource.kubeconfig, helm_release.nginx_ingress]
  name             = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "tools"
  create_namespace = true
  values           = [file("${path.module}/helm-values/argo.yml")]

  # set ingress
  set {
      name  = "global.domain"
      value = "argocd-${var.env}.maidevops.fun"
    }
}

# install external secret tool to read vault secrets
# External Secrets Operator integrates with HashiCorp Vault for secret management.
resource "helm_release" "external-secrets" {
  depends_on       = [null_resource.kubeconfig]
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  namespace        = "tools"
  create_namespace = true
}

# created ClusterSecretStore
resource "null_resource" "external-secret-store" {
  depends_on = [helm_release.external-secrets]

  provisioner "local-exec" {
    command = <<EOF
kubectl apply -f - <<EOK
apiVersion: v1
kind: Secret
metadata:
  name: vault-token
  namespace: tools
data:
  token: ${base64encode(var.vault_token)}
---
apiVersion: external-secrets.io/v1
kind: ClusterSecretStore
metadata:
  name: vault-backend
  namespace: tools
spec:
  provider:
    vault:
      server: "http://vault-internal.maidevops.fun:8200"
      path: "roboshop-${var.env}"
      version: "v2"
      auth:
        tokenSecretRef:
          name: "vault-token"
          key: "token"
          namespace: tools
EOK
EOF
  }
}