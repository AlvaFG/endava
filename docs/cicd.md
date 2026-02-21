# CI/CD Pipeline

## Flujo del Pipeline

```
Push a main (app/ o helm/)
        │
        ▼
┌───────────────┐
│   test job    │
│               │
│ • Setup Python│
│ • pip install │
│ • flake8 lint │
│ • Run tests   │
└───────┬───────┘
        │ (solo en main)
        ▼
┌───────────────────┐
│ build-and-push    │
│                   │
│ • Login GHCR      │
│ • Docker build    │
│ • Push con SHA tag│
│ • Push :latest    │
│ • Update values   │
│ • Git commit+push │
└───────────────────┘
        │
        ▼
ArgoCD detecta cambio → sync → deploy
```

## Detalles

### Trigger
- Push a `main` que modifique `app/`, `helm/` o el workflow mismo
- Pull requests a `main` (solo test, no build)

### Test Job
1. Checkout código
2. Setup Python 3.12
3. Instalar dependencias (`requirements.txt`)
4. Lint con flake8 (max-line-length 120)
5. Test básico: verifica que `/health` retorna 200

### Build and Push Job
1. Login a GitHub Container Registry (ghcr.io)
2. Build imagen Docker con multi-stage
3. Push con dos tags: `SHA` del commit y `latest`
4. Actualiza `helm/demo-app/values.yaml` con el nuevo tag
5. Commit y push del cambio (esto triggerea ArgoCD)

### Seguridad
- Usa `GITHUB_TOKEN` (automático, no requiere secrets manuales)
- Permisos mínimos: `contents: write`, `packages: write`
- La imagen queda en ghcr.io asociada al repo

### GitOps Loop
```
CI actualiza tag en values.yaml
        │
        ▼
ArgoCD detecta diff entre Git y cluster
        │
        ▼
ArgoCD aplica helm upgrade automáticamente
        │
        ▼
Kubernetes hace rolling update
```
