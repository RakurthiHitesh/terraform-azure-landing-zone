#!/bin/bash
# ============================================================
# bootstrap.sh — Create Azure remote state storage
# Run this ONCE before terraform init
# Usage: ./scripts/bootstrap.sh
# ============================================================

set -e

RESOURCE_GROUP="rg-terraform-state"
STORAGE_ACCOUNT="tfstatehitesh"
CONTAINER_NAME="tfstate"
LOCATION="uksouth"

echo "============================================"
echo " Bootstrapping Terraform Remote State"
echo " Storage: $STORAGE_ACCOUNT"
echo " Location: $LOCATION"
echo "============================================"

# Login check
echo "[INFO] Checking Azure login..."
az account show > /dev/null 2>&1 || { echo "[ERROR] Please run 'az login' first"; exit 1; }

# Create resource group
echo "[INFO] Creating resource group: $RESOURCE_GROUP"
az group create \
  --name "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --output none

# Create storage account
echo "[INFO] Creating storage account: $STORAGE_ACCOUNT"
az storage account create \
  --name "$STORAGE_ACCOUNT" \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --min-tls-version TLS1_2 \
  --output none

# Create blob container
echo "[INFO] Creating blob container: $CONTAINER_NAME"
az storage container create \
  --name "$CONTAINER_NAME" \
  --account-name "$STORAGE_ACCOUNT" \
  --output none

echo ""
echo "[SUCCESS] Remote state storage ready!"
echo ""
echo "Now run:"
echo "  terraform init"
echo "  terraform plan -var-file=environments/dev/terraform.tfvars"
