#!/bin/bash
set -euo pipefail

# Bootstrap script para el cluster EKS
# Uso: ./scripts/setup-cluster.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "============================================"
echo "  Endava Demo - Cluster Bootstrap"
echo "============================================"

# 1. Verificar herramientas
echo ""
echo ">>> Verificando herramientas..."
for tool in aws kubectl helm; do
  if ! command -v $tool &>/dev/null; then
    echo "ERROR: $tool no está instalado"
    exit 1
  fi
  echo "  ✓ $tool"
done

# 2. Terraform apply para EKS
echo ""
echo ">>> Creando infraestructura con Terraform..."
cd "$PROJECT_DIR/terraform/aws/eks"
terraform init
terraform plan -out=tfplan
echo ""
read -p "¿Aplicar el plan de Terraform? (y/n): " confirm
if [ "$confirm" = "y" ]; then
  terraform apply tfplan
else
  echo "Abortado."
  exit 0
fi

# 3. Configurar kubectl
echo ""
echo ">>> Configurando kubectl..."
CLUSTER_NAME=$(terraform output -raw cluster_name)
REGION=$(terraform output -raw region 2>/dev/null || echo "us-east-1")
aws eks update-kubeconfig --region "$REGION" --name "$CLUSTER_NAME"

echo ""
echo ">>> Verificando nodos..."
kubectl get nodes

# 4. Instalar ArgoCD
echo ""
echo ">>> Instalando ArgoCD..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
echo "Esperando a que ArgoCD esté listo..."
kubectl -n argocd rollout status deployment argocd-server --timeout=300s

# 5. Obtener password de ArgoCD
ARGOCD_PASS=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo ""
echo ">>> ArgoCD instalado!"
echo "  Usuario: admin"
echo "  Password: $ARGOCD_PASS"

# 6. Aplicar App-of-Apps
echo ""
echo ">>> Configurando ArgoCD..."
kubectl apply -f "$PROJECT_DIR/k8s/argocd/app-of-apps.yaml"

echo ""
echo "============================================"
echo "  Bootstrap completado!"
echo ""
echo "  Para acceder a ArgoCD UI:"
echo "    kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "    Abrir: https://localhost:8080"
echo ""
echo "  Para acceder a Grafana:"
echo "    kubectl port-forward svc/monitoring-grafana -n monitoring 3000:80"
echo "    Abrir: http://localhost:3000"
echo "============================================"
