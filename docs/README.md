# Endava Platform Engineering Demo

## Overview

Proyecto de demostración de Platform Engineering que implementa una plataforma completa en AWS usando herramientas open source. Demuestra competencias en infraestructura como código, contenedores, GitOps, CI/CD, observabilidad y automatización.

## Arquitectura

```
                    ┌─────────────────────────────────────────────────┐
                    │                   GitHub                         │
                    │  ┌──────────┐    ┌──────────┐    ┌───────────┐ │
                    │  │ App Code │───▶│ CI/CD    │───▶│ Container │ │
                    │  │          │    │ (Actions)│    │ Registry  │ │
                    │  └──────────┘    └────┬─────┘    │ (ghcr.io) │ │
                    │                       │          └───────────┘ │
                    └───────────────────────┼─────────────────────────┘
                                            │ git push (image tag)
                    ┌───────────────────────▼─────────────────────────┐
                    │              AWS EKS Cluster                     │
                    │                                                  │
                    │  ┌──────────┐  ┌───────────┐  ┌──────────────┐ │
                    │  │ ArgoCD   │  │ Ingress   │  │ cert-manager │ │
                    │  │ (GitOps) │  │ (NGINX)   │  │ (TLS)        │ │
                    │  └────┬─────┘  └───────────┘  └──────────────┘ │
                    │       │                                         │
                    │  ┌────▼─────┐  ┌───────────┐  ┌──────────────┐ │
                    │  │ Demo App │  │Prometheus │  │   Grafana    │ │
                    │  │ (Flask)  │  │           │  │              │ │
                    │  └──────────┘  └───────────┘  └──────────────┘ │
                    │                                                  │
                    │  VPC: 10.0.0.0/16 (public + private subnets)   │
                    └──────────────────────────────────────────────────┘

                    ┌──────────────────────────────────────────────────┐
                    │              Ansible                              │
                    │  Linux VMs: setup, hardening, monitoring         │
                    │  Windows VMs: chocolatey, WinRM, updates        │
                    │  K8s tools: kubectl, helm, k9s                   │
                    └──────────────────────────────────────────────────┘
```

## Stack Tecnológico

| Categoría | Herramienta |
|-----------|------------|
| IaC | Terraform |
| Contenedores | Docker, Kubernetes (EKS) |
| Package Manager | Helm |
| GitOps | ArgoCD |
| CI/CD | GitHub Actions |
| Ingress | NGINX Ingress Controller |
| TLS | cert-manager + Let's Encrypt |
| Observabilidad | Prometheus + Grafana + AlertManager |
| Automatización | Ansible (Linux + Windows) |
| Cloud | AWS |

## Estructura del Proyecto

```
├── terraform/aws/eks/    # Infraestructura EKS + VPC
├── terraform/aws/vm/     # VMs EC2 (demo multi-cloud)
├── ansible/              # Playbooks y roles
├── app/                  # Aplicación de ejemplo (Flask)
├── helm/demo-app/        # Helm chart
├── k8s/                  # Manifiestos Kubernetes + ArgoCD
├── .github/workflows/    # CI/CD pipeline
├── scripts/              # Scripts de utilidad
└── docs/                 # Documentación
```

## Quick Start

Ver [runbook.md](runbook.md) para la guía paso a paso.

```bash
# 1. Crear infraestructura
cd terraform/aws/eks && terraform init && terraform apply

# 2. Configurar kubectl
aws eks update-kubeconfig --region us-east-1 --name endava-demo-cluster

# 3. Bootstrap del cluster (ArgoCD + apps)
./scripts/setup-cluster.sh
```

## Documentación

- [Arquitectura](architecture.md) - Diseño y decisiones técnicas
- [Terraform](terraform.md) - Infraestructura como código
- [Ansible](ansible.md) - Automatización de configuración
- [Kubernetes](kubernetes.md) - Helm, ArgoCD, GitOps
- [CI/CD](cicd.md) - Pipeline de integración y despliegue
- [Monitoreo](monitoring.md) - Observabilidad
- [Runbook](runbook.md) - Guía paso a paso
