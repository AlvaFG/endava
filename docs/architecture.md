# Arquitectura

## Diagrama de Flujo

```
Developer ──push──▶ GitHub ──trigger──▶ GitHub Actions
                                              │
                                    ┌─────────┴─────────┐
                                    │ 1. Lint + Test     │
                                    │ 2. Build Docker    │
                                    │ 3. Push ghcr.io    │
                                    │ 4. Update tag      │
                                    └─────────┬──────────┘
                                              │ git commit (new tag)
                                              ▼
                                    ┌────────────────────┐
                                    │     ArgoCD         │
                                    │  (detecta cambio)  │
                                    └─────────┬──────────┘
                                              │ sync
                                              ▼
                                    ┌────────────────────┐
                                    │   EKS Cluster      │
                                    │  ┌──────────────┐  │
                                    │  │  Demo App    │  │
                                    │  │  (new image) │  │
                                    │  └──────────────┘  │
                                    └────────────────────┘
```

## Decisiones de Diseño

### ¿Por qué EKS?
- Managed control plane reduce overhead operacional
- Integración nativa con IAM, VPC, ALB
- Managed node groups simplifican el lifecycle de los nodos

### ¿Por qué ArgoCD para GitOps?
- Git como single source of truth
- Reconciliación automática: si alguien modifica algo manualmente, ArgoCD lo revierte
- UI visual para ver el estado de los deployments
- App-of-apps pattern para gestionar múltiples aplicaciones declarativamente

### ¿Por qué NGINX Ingress + cert-manager?
- NGINX es el ingress controller más maduro y documentado
- cert-manager automatiza la obtención y renovación de certificados TLS
- Combinación probada en producción

### ¿Por qué kube-prometheus-stack?
- Solución todo-en-uno: Prometheus + Grafana + AlertManager
- ServiceMonitor CRDs para descubrimiento automático de targets
- Dashboards pre-configurados para el cluster

### Networking
- VPC con subnets públicas (ingress, NAT) y privadas (nodos EKS)
- NAT Gateway para que los nodos accedan a internet sin exposición pública
- Multi-AZ para alta disponibilidad
- Tags de Kubernetes en subnets para integración con ELB

### Seguridad
- Nodos en subnets privadas
- IAM roles con least privilege (separados para cluster y nodos)
- Pod security: non-root containers, resource limits
- TLS en ingress con Let's Encrypt
- Ansible hardening: firewall, SSH sin password, usuario sin root
