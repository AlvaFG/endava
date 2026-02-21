# Ansible

## Estructura

```
ansible/
├── ansible.cfg
├── inventory/
│   └── hosts.yml           # Inventario multi-cloud
├── playbooks/
│   ├── setup.yml           # Setup Linux básico
│   ├── monitoring.yml      # Node Exporter
│   ├── setup-windows.yml   # Setup Windows (WinRM)
│   └── k8s-tools.yml       # kubectl, helm, k9s
└── roles/
    ├── common/             # Paquetes base, timezone, usuario admin
    ├── hardening/          # SSH hardening, UFW firewall
    └── monitoring/         # Node Exporter setup
```

## Roles

### common
- Actualización de paquetes
- Instalación de herramientas esenciales (htop, curl, vim, git, jq, tmux)
- Configuración de timezone UTC
- Creación de usuario admin

### hardening
- Deshabilitar login con password (SSH)
- Deshabilitar login root
- UFW firewall: deny por defecto, allow SSH y Node Exporter

### monitoring
- Node Exporter como servicio systemd
- Health check script + cron cada 6 horas
- Limpieza de archivos temporales

## Playbooks

### setup-windows.yml
Demuestra capacidad de gestionar Windows con Ansible:
- Chocolatey para gestión de paquetes
- Creación de usuarios administradores
- WinRM sobre HTTPS
- Windows Firewall rules
- Windows Updates (seguridad + críticas)

### k8s-tools.yml
Instala herramientas de Kubernetes en VMs:
- kubectl v1.29
- Helm v3.14
- k9s (TUI para Kubernetes)

## Ejecución

```bash
# Linux setup con roles
ansible-playbook -i inventory/hosts.yml playbooks/setup.yml

# Monitoreo
ansible-playbook -i inventory/hosts.yml playbooks/monitoring.yml

# Herramientas K8s
ansible-playbook -i inventory/hosts.yml playbooks/k8s-tools.yml

# Windows (requiere inventario con vars WinRM)
ansible-playbook -i inventory/hosts.yml playbooks/setup-windows.yml
```

## Windows vs Linux

| Aspecto | Linux | Windows |
|---------|-------|---------|
| Conexión | SSH | WinRM |
| Paquetes | apt/yum | Chocolatey |
| Firewall | UFW | win_firewall_rule |
| Updates | apt upgrade | win_updates |
| Usuarios | user module | win_user module |
