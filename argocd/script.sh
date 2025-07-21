#!/bin/bash

ARGOCD_NAMESPACE="argocd"
MONITORING_NAMESPACE="monitoring"

echo "Creating ArgoCD namespace..."
kubectl create namespace $ARGOCD_NAMESPACE || true
if [ $? -ne 0 ]; then
    echo "Failed to create namespace $ARGOCD_NAMESPACE. It may already exist."
fi
kubectl apply -n $ARGOCD_NAMESPACE -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64
argocd version
argocd login --core
echo "ArgoCD installed successfully."
echo "Creating Monitoring namespace..."
kubectl create namespace $MONITORING_NAMESPACE || true
if [ $? -ne 0 ]; then
    echo "Failed to create namespace $MONITORING_NAMESPACE. It may already exist."
fi
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm upgrade --install kube-prometheus prometheus-community/kube-prometheus-stack --namespace $MONITORING_NAMESPACE --create-namespace --set grafana.adminPassword=admin
kubectl apply -f <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: monitoring-stack
  namespace: argocd
spec:
  destination:
    namespace: monitoring
    server: https://kubernetes.default.svc
  project: default
  source:
    repoURL: https://github.com/your/repo.git
    targetRevision: HEAD
    path: monitoring
  syncPolicy:
    automated:
      selfHeal: true
      prune: true
EOF
echo "Monitoring stack deployed successfully."
kubectl apply -f ingress.yaml
kubectl apply -f service.yaml
kubectl apply -f deployment.yaml
kubectl apply -f application.yaml
echo "Yaml files applied successfully."