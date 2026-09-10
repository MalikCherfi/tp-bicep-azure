#!/usr/bin/env bash
set -euo pipefail

RG="mcherfiRG"
LOCATION="francecentral"
IDENTITY_NAME="github-mi-malikcherfi"
GITHUB_REPO="tp-bicep-azure"
BRANCH="main"

# Liste des Resource Groups cibles
TARGET_RGS=(
  "rg-malik-cherfi-tp104-vm"
  "rg-malik-cherfi-tp104-vmss"
  "rg-malik-cherfi-tp104-appservice"
  "rg-malik-cherfi-tp104-aci"
)

SUB_ID=$(az account show --query id -o tsv)
TENANT_ID=$(az account show --query tenantId -o tsv)

# Récupération des IDs de la Managed Identity existante
PRINCIPAL_ID=$(az identity show --name "$IDENTITY_NAME" --resource-group "$RG" --query principalId -o tsv)
CLIENT_ID=$(az identity show --name "$IDENTITY_NAME" --resource-group "$RG" --query clientId -o tsv)

echo "Attribution du rôle Contributor sur chaque Resource Group..."
for TARGET_RG in "${TARGET_RGS[@]}"; do
  echo "-> Configuration pour $TARGET_RG"

  # S'assure que le RG existe avant d'assigner le rôle
  az group create --name "$TARGET_RG" --location "$LOCATION" --output none

  RG_SCOPE="/subscriptions/$SUB_ID/resourceGroups/$TARGET_RG"

  # Assignation du rôle Contributor
  az role assignment create \
    --assignee "$PRINCIPAL_ID" \
    --role "Contributor" \
    --scope "$RG_SCOPE" \
    --output none || true
done

echo "Configuration des Federated Credentials sur l'identité..."

# Federated Credential pour la branche main
az identity federated-credential create \
  --name "github-${GITHUB_REPO}-${BRANCH}-main" \
  --identity-name "$IDENTITY_NAME" \
  --resource-group "$RG" \
  --issuer "https://token.actions.githubusercontent.com" \
  --subject "repo:MalikCherfi@90403152/${GITHUB_REPO}@1317064255:ref:refs/heads/main" \
  --audiences "api://AzureADTokenExchange" \
  --output none || true

# Federated Credential pour les Pull Requests
az identity federated-credential create \
  --name "github-${GITHUB_REPO}-${BRANCH}-pull-requests" \
  --identity-name "$IDENTITY_NAME" \
  --resource-group "$RG" \
  --issuer "https://token.actions.githubusercontent.com" \
  --subject "repo:MalikCherfi@90403152/${GITHUB_REPO}@1317064255:pull_request" \
  --audiences "api://AzureADTokenExchange" \
  --output none || true

echo "=== Terminé ==="
echo "AZURE_CLIENT_ID=$CLIENT_ID"
echo "AZURE_TENANT_ID=$TENANT_ID"
echo "AZURE_SUBSCRIPTION_ID=$SUB_ID"