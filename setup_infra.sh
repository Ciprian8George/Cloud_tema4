#!/bin/bash

# --- CONFIGURARE ---
# Folosim Sweden Central sau France Central pentru ca au cota mai buna la OpenAI decat Germania
LOCATION="germanywestcentral"
PROJECT_PREFIX="tema4"

# Generare ID unic (ca sa nu ai conflicte de nume DNS)
RANDOM_ID=$(openssl rand -hex 3)
RESOURCE_GROUP="${PROJECT_PREFIX}-${RANDOM_ID}-rg"
APP_PLAN="${PROJECT_PREFIX}${RANDOM_ID}plan"
WEB_APP_NAME="${PROJECT_PREFIX}${RANDOM_ID}app"
OPENAI_NAME="${PROJECT_PREFIX}${RANDOM_ID}ai"
DEPLOYMENT_NAME="gpt-4-1-nano-2025-04-14-ft-06fd23b813f2417ba7ad880bb65b49d7"

echo "=========================================="
echo "   START SETUP INFRASTRUCTURA AZURE"
echo "=========================================="
echo "Resource Group: $RESOURCE_GROUP"
echo "Web App Name:   $WEB_APP_NAME"
echo "Region:         $LOCATION"
echo "=========================================="

# 1. Creare Resource Group
echo "--> 1. Creare Resource Group..."
az group create --name $RESOURCE_GROUP --location $LOCATION --output none

# 2. Creare App Service Plan (B1 - Basic, Linux)
echo "--> 2. Creare App Service Plan..."
az appservice plan create --name $APP_PLAN --resource-group $RESOURCE_GROUP --sku B1 --is-linux --output none

# 3. Creare Web App (Python 3.10)
echo "--> 3. Creare Web App..."
az webapp create --name $WEB_APP_NAME --resource-group $RESOURCE_GROUP --plan $APP_PLAN --runtime "PYTHON:3.10" --output none

# 4. Creare Cont Azure OpenAI
echo "--> 4. Creare Resursa Azure OpenAI (poate dura putin)..."
az cognitiveservices account create \
  --name $OPENAI_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --kind OpenAI \
  --sku S0 \
  --yes --output none

# 5. Deploy Model GPT-3.5
echo "--> 5. Deploy Model GPT-3.5 Turbo..."
az cognitiveservices account deployment create \
  --name $OPENAI_NAME \
  --resource-group $RESOURCE_GROUP \
  --deployment-name $DEPLOYMENT_NAME \
  --model-name "gpt-35-turbo" \
  --model-version "0613" \
  --model-format OpenAI \
  --sku-capacity 120 --sku-name "Standard" --output none

# 6. Configurare Web App (Chei și Setări)
echo "--> 6. Configurare Variabile de Mediu in Web App..."

# Extragere chei
API_ENDPOINT=$(az cognitiveservices account show --name $OPENAI_NAME --resource-group $RESOURCE_GROUP --query properties.endpoint --output tsv)
API_KEY=$(az cognitiveservices account keys list --name $OPENAI_NAME --resource-group $RESOURCE_GROUP --query key1 --output tsv)

# Setare variabile in cloud
az webapp config appsettings set --name $WEB_APP_NAME --resource-group $RESOURCE_GROUP --settings \
  AZURE_OPENAI_ENDPOINT="$API_ENDPOINT" \
  AZURE_OPENAI_API_KEY="$API_KEY" \
  DEPLOYMENT_NAME="$DEPLOYMENT_NAME" \
  SCM_DO_BUILD_DURING_DEPLOYMENT="true" --output none

# Configurare comanda de start (important pentru Gunicorn/Flask)
az webapp config set --resource-group $RESOURCE_GROUP --name $WEB_APP_NAME --startup-file "gunicorn --bind=0.0.0.0 --timeout 600 app:app" --output none

# 7. Salvare configuratie locala
echo "--> 7. Salvare configuratie in .azure_config..."
echo "RESOURCE_GROUP=$RESOURCE_GROUP" > .azure_config
echo "WEB_APP_NAME=$WEB_APP_NAME" >> .azure_config

echo "=========================================="
echo "SETUP COMPLET! Acum ruleaza: ./deploy_app.sh"
echo "=========================================="