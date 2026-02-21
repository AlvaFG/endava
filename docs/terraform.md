# Terraform

## Estructura

```
terraform/
├── aws/
│   ├── eks/          # Cluster EKS + VPC completa
│   │   ├── main.tf
│   │   ├── vpc.tf
│   │   ├── eks.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── vm/           # EC2 instance (demo original)
├── azure/            # Azure VM
└── huawei/           # Huawei Cloud VM
```

## Módulo EKS

### VPC (vpc.tf)
- CIDR: `10.0.0.0/16`
- 2 subnets públicas (`10.0.1.0/24`, `10.0.2.0/24`) - para load balancers
- 2 subnets privadas (`10.0.10.0/24`, `10.0.11.0/24`) - para nodos EKS
- Internet Gateway + NAT Gateway
- Route tables separadas para público/privado
- Tags de Kubernetes para integración con ELB controller

### EKS (eks.tf)
- Cluster v1.29 con endpoint público+privado
- IAM role para cluster con `AmazonEKSClusterPolicy`
- IAM role para nodos con Worker, CNI y ECR policies
- Managed node group: 2x t3.medium (escalable 1-3)

### Variables clave
| Variable | Default | Descripción |
|----------|---------|-------------|
| `region` | us-east-1 | Región AWS |
| `cluster_version` | 1.29 | Versión de Kubernetes |
| `node_instance_type` | t3.medium | Tipo de instancia para nodos |
| `node_desired_size` | 2 | Nodos deseados |

### Uso

```bash
cd terraform/aws/eks
terraform init
terraform plan
terraform apply

# Configurar kubectl
$(terraform output -raw configure_kubectl)
```

### Costos estimados
- EKS control plane: ~$75/mes
- 2x t3.medium: ~$60/mes
- NAT Gateway: ~$32/mes + datos
- **Total: ~$170/mes**

> Para reducir costos: 1 nodo t3.small (~$100/mes total)
