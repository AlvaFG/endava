# Observabilidad

## Stack

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│ Prometheus  │────▶│  Grafana    │     │AlertManager │
│ (métricas)  │     │ (dashboards)│     │ (alertas)   │
└──────┬──────┘     └─────────────┘     └─────────────┘
       │ scrape
       │
┌──────┴──────────────────────────────┐
│          Targets                     │
│                                      │
│  ┌──────────┐  ┌──────────────────┐ │
│  │ Demo App │  │ Node Exporter    │ │
│  │ /metrics │  │ (VMs via Ansible)│ │
│  └──────────┘  └──────────────────┘ │
│                                      │
│  ┌──────────────────┐               │
│  │ kube-state-metrics│               │
│  │ (cluster health)  │               │
│  └──────────────────┘               │
└──────────────────────────────────────┘
```

## Instalación

Se instala via ArgoCD usando `kube-prometheus-stack` Helm chart. Incluye:
- Prometheus (con persistent storage 10Gi)
- Grafana (con persistent storage 5Gi)
- AlertManager (con persistent storage 2Gi)
- kube-state-metrics
- node-exporter (en cada nodo del cluster)

## Métricas de la App

La demo app expone en `/metrics`:
- `app_requests_total` (Counter) - Total de requests por método, endpoint y status
- `app_request_latency_seconds` (Histogram) - Latencia por endpoint

## ServiceMonitor

El Helm chart incluye un `ServiceMonitor` que le dice a Prometheus que scrape la app:
```yaml
endpoints:
  - port: http
    path: /metrics
    interval: 30s
```

## Dashboard Personalizado

`k8s/monitoring/grafana/dashboard-app.json` incluye:
- Request rate (requests/sec por endpoint)
- Latencia p95
- Error rate (% de 5xx)

## Acceso

```bash
# Grafana
kubectl port-forward svc/monitoring-grafana -n monitoring 3000:80
# Usuario: admin, Password: admin

# Prometheus
kubectl port-forward svc/monitoring-kube-prometheus-prometheus -n monitoring 9090:9090
```
