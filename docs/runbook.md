# Runbook - Guía paso a paso

## Pre-requisitos

```bash
# Herramientas necesarias
aws --version          # AWS CLI v2
terraform --version    # >= 1.0
kubectl version        # >= 1.29
helm version           # >= 3.14
git --version
docker --version       # (para builds locales)
```

## Paso 1: Configurar AWS

```bash
aws configure
# Access Key, Secret Key, Region: us-east-1
```

## Paso 2: Crear infraestructura EKS

```bash
cd terraform/aws/eks
terraform init
terraform plan          # Revisar el plan
terraform apply         # Confirmar con "yes"

# Guardar el comando de kubectl
terraform output configure_kubectl
```

> Tiempo estimado: ~15 minutos

## Paso 3: Configurar kubectl

```bash
aws eks update-kubeconfig --region us-east-1 --name endava-demo-cluster

# Verificar
kubectl get nodes
# Deberían aparecer 2 nodos Ready
```

## Paso 4: Bootstrap del cluster (opción rápida)

```bash
./scripts/setup-cluster.sh
# Esto instala ArgoCD y configura app-of-apps
```

## Paso 4 (alternativa): Setup manual

### 4a. Instalar ArgoCD

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Esperar
kubectl -n argocd rollout status deployment argocd-server

# Password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### 4b. Aplicar App-of-Apps

```bash
kubectl apply -f k8s/argocd/app-of-apps.yaml
```

Esto desplegará automáticamente:
- ingress-nginx
- cert-manager
- kube-prometheus-stack (Prometheus + Grafana)
- demo-app

### 4c. Verificar despliegues

```bash
# Ver estado en ArgoCD
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Abrir https://localhost:8080

# O por CLI
kubectl get pods -A
```

## Paso 5: Verificar la app

```bash
# Port-forward directo
kubectl port-forward svc/demo-app -n demo 8080:80

# Probar endpoints
curl http://localhost:8080/health
curl http://localhost:8080/info
curl http://localhost:8080/metrics
```

## Paso 6: Verificar monitoreo

```bash
# Grafana
kubectl port-forward svc/monitoring-grafana -n monitoring 3000:80
# http://localhost:3000 (admin/admin)

# Prometheus
kubectl port-forward svc/monitoring-kube-prometheus-prometheus -n monitoring 9090:9090
# http://localhost:9090
```

## Paso 7: Probar el flujo CI/CD completo

```bash
# Modificar la app
echo "# test change" >> app/app.py
git add . && git commit -m "test: trigger CI/CD"
git push

# Observar:
# 1. GitHub Actions ejecuta el pipeline
# 2. Nueva imagen pusheada a ghcr.io
# 3. values.yaml actualizado con nuevo tag
# 4. ArgoCD sincroniza automáticamente
# 5. Pods actualizados con rolling update
```

## Paso 8: Ejecutar Ansible (VMs)

```bash
cd ansible

# Setup Linux
ansible-playbook -i inventory/hosts.yml playbooks/setup.yml

# Monitoreo
ansible-playbook -i inventory/hosts.yml playbooks/monitoring.yml

# Herramientas K8s
ansible-playbook -i inventory/hosts.yml playbooks/k8s-tools.yml
```

## Cleanup

```bash
# Destruir cluster EKS
cd terraform/aws/eks
terraform destroy

# Destruir VMs
cd terraform/aws/vm
terraform destroy
```

> **IMPORTANTE:** Hacer destroy cuando no se esté usando para evitar costos innecesarios.
