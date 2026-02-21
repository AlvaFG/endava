#!/bin/bash
# Script para verificar estado de créditos y recursos en cada cloud

echo "============================================"
echo "  Multi-Cloud Credits & Resources Check"
echo "  $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
echo "============================================"

# --- AWS ---
echo ""
echo ">>> AWS <<<"
if command -v aws &>/dev/null; then
  echo "Account ID: $(aws sts get-caller-identity --query Account --output text 2>/dev/null || echo 'Error')"
  echo "Region: $(aws configure get region 2>/dev/null || echo 'Not set')"
  echo "EC2 instances:"
  aws ec2 describe-instances \
    --query 'Reservations[].Instances[].[InstanceId,State.Name,InstanceType,PublicIpAddress]' \
    --output table 2>/dev/null || echo "  Error querying EC2"
else
  echo "  AWS CLI not installed"
fi

# --- OCI ---
echo ""
echo ">>> Oracle Cloud <<<"
if command -v oci &>/dev/null; then
  echo "Tenancy: $(oci iam tenancy get --query 'data.name' --raw-output 2>/dev/null || echo 'Error')"
  echo "Compute instances:"
  oci compute instance list \
    --compartment-id "$(oci iam compartment list --query 'data[0].id' --raw-output 2>/dev/null)" \
    --query 'data[].[\"display-name\",\"lifecycle-state\",\"shape\"]' \
    --output table 2>/dev/null || echo "  Error querying OCI"
else
  echo "  OCI CLI not installed"
fi

# --- Huawei Cloud ---
echo ""
echo ">>> Huawei Cloud <<<"
if command -v hcloud &>/dev/null; then
  echo "Config:"
  hcloud configure show 2>/dev/null || echo "  Not configured"
else
  echo "  Huawei Cloud CLI not installed"
  echo "  Check console: https://console.huaweicloud.com"
fi

# --- Azure ---
echo ""
echo ">>> Azure <<<"
if command -v az &>/dev/null; then
  echo "Account:"
  az account show --query '{Name:name, State:state, SubscriptionId:id}' --output table 2>/dev/null || echo "  Not logged in (run: az login)"
else
  echo "  Azure CLI not installed"
fi

echo ""
echo "============================================"
echo "  Check complete"
echo "============================================"
