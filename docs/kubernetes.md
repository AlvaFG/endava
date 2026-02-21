# Kubernetes, Helm y GitOps

## Helm Chart (demo-app)

```
helm/demo-app/
├── Chart.yaml
├── values.yaml
└── templates/
    ├── _helpers.tpl
    ├── deployment.yaml
    ├── service.yaml
    ├── ingress.yaml
    ├── hpa.yaml
    └── servicemonitor.yaml
```

### Features del chart
- **Deployment** con health checks (liveness + readiness)
- **Service** ClusterIP
- **Ingress** con NGINX + TLS (cert-manager)
- **HPA** auto-scaling basado en CPU (2-5 replicas)
- **ServiceMonitor** para que Prometheus scrape `/metrics`
- Variables de entorno inyectadas (incluyendo POD_NAMESPACE del downward API)

### Uso

```bash
# Instalar
helm install demo-app helm/demo-app -n demo --create-namespace

# Upgrade con valores custom
helm upgrade demo-app helm/demo-app -n demo --set image.tag=abc123

# Dry-run para verificar templates
helm template demo-app helm/demo-app
```

## GitOps con ArgoCD

### Flujo

```
1. Developer pushea código a GitHub
2. GitHub Actions: test → build → push imagen → actualiza tag en values.yaml
3. ArgoCD detecta el cambio en el repo (polling cada 3 min)
4. ArgoCD sincroniza: aplica los manifiestos actualizados al cluster
5. Kubernetes hace rolling update del deployment
```

### App-of-Apps Pattern

Un solo Application CRD (`app-of-apps.yaml`) gestiona todas las demás apps:

```
app-of-apps
├── demo-app          (Helm chart local)
├── monitoring        (kube-prometheus-stack desde Helm repo)
├── ingress-nginx     (desde Helm repo)
└── cert-manager      (desde Helm repo)
```

Esto permite:
- Agregar/eliminar apps con solo crear/borrar un YAML en `k8s/apps/`
- Todas las apps se gestionan declarativamente
- Self-healing: si alguien modifica algo manualmente, ArgoCD lo revierte

### Acceso a ArgoCD

```bash
# Port-forward
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Password inicial
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```
