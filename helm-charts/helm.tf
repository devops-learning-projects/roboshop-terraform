# Added kubeconfig
resource "null_resource" "kubeconfig" {
  triggers = {
    always = timestamp()
  }
  provisioner "local-exec" {
    command = <<EOF
aws eks update-kubeconfig --name ${var.env}
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
EOF
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
  # values           = [file("${path.module}/helm-values/ingress.yml")]
  values = [templatefile("${path.module}/helm-values/ingress.yml",
    {
      lb_subnets      = join(",", data.aws_subnets.lb-az.ids)
      internal_lb_ips = var.internal_lb_ips
    }
  )]
}

# We moved this to ALB, Hence we are going to create DNS to public load balancer.
# download external dns to automate dns creation
# resource "helm_release" "external-dns" {
#   depends_on       = [null_resource.kubeconfig]
#   name             = "external-dns"
#   repository       = "https://kubernetes-sigs.github.io/external-dns"
#   chart            = "external-dns"
#   namespace        = "tools"
#   create_namespace = true
# }

#
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
  token: ${base64encode(var.token)}
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

# install prometheus and grafana
resource "helm_release" "prometheus" {
  depends_on       = [null_resource.kubeconfig, helm_release.nginx_ingress]
  name             = "kube-prometheus-stack"
  repository       = "oci://ghcr.io/prometheus-community/charts"
  chart            = "kube-prometheus-stack"
  namespace        = "tools"
  create_namespace = true
  # values           = [file("${path.module}/helm-values/kube-stack.yml")]
  values           = [
    templatefile("${path.module}/helm-values/kube-stack.yml", {
      smtp_user = data.vault_generic_secret.ses.data["smtp_user"]
      smtp_pass = data.vault_generic_secret.ses.data["smtp_pass"]
    })
  ]

  set_list {
    name  = "prometheus.ingress.hosts"
    value = ["prometheus-${var.env}.maidevops.fun"]
  }

  set_list {
    name  = "alertmanager.ingress.hosts"
    value = ["alertmanager-${var.env}.maidevops.fun"]
  }
}

# Cluster Autoscaler
resource "helm_release" "cluster-autoscaler" {
  depends_on       = [null_resource.kubeconfig, aws_eks_pod_identity_association.cluster-autoscaler]
  name             = "cluster-autoscaler"
  repository       = "https://kubernetes.github.io/autoscaler"
  chart            = "cluster-autoscaler"
  namespace        = "tools"
  create_namespace = true
  values           = [file("${path.module}/helm-values/kube-stack.yml")]

  set {
    name  = "autoDiscovery.clusterName"
    value = var.env
  }

  set {
    name  = "awsRegion"
    value = "us-east-1"
  }
}

# Filebeat Helm Chart
resource "helm_release" "filebeat" {
  name       = "filebeat"
  repository = "https://helm.elastic.co"
  chart      = "filebeat"
  namespace  = "kube-system"
  wait       = "false"

  values = [
    file("${path.module}/helm-values/filebeat.yml")
  ]

}

# cert-manager and let's encrypt certificate
resource "helm_release" "cert-manager" {
  depends_on       = [null_resource.kubeconfig]
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "tools"
  create_namespace = true

  set {
    name  = "crds.enabled"
    value = "true"
  }
}

resource "null_resource" "cert-manager-cluster-issuer" {
  depends_on = [null_resource.kubeconfig, helm_release.cert-manager]

  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/helm-values/cluster-issuer.yml"
  }
}