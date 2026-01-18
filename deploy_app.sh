#!/bin/bash

CONFIG_FILE=".azure_config"

echo "=========================================="
echo "      DEPLOYMENT SCRIPT - TEMA 4"
echo "=========================================="

# 1. Verificare config
if [ ! -f "$CONFIG_FILE" ]; then
    echo "EROARE: Nu gasesc fisierul $CONFIG_FILE."
    echo "Ruleaza intai ./setup_infra.sh pentru a crea resursele."
    exit 1
fi

# 2. Incarcare variabile
source $CONFIG_FILE
echo "Target Web App: $WEB_APP_NAME"
echo "Target RG:      $RESOURCE_GROUP"

# 3. Verificare existenta in Cloud
echo "--> Verificare status resurse..."
EXISTS=$(az group exists --name $RESOURCE_GROUP)
if [ "$EXISTS" == "false" ]; then
    echo "EROARE: Grupul de resurse $RESOURCE_GROUP nu mai exista in Azure!"
    exit 1
fi

# 4. Creare Arhiva
echo "--> Impachetare cod (zip)..."
rm -f deploy.zip
# Excludem fisierele inutile (venv, git, cache, etc.)
zip -r deploy.zip . -x "venv/*" -x ".git/*" -x "__pycache__/*" -x "*.sh" -x ".env" -x ".azure_config" -x "*.zip" > /dev/null

# 5. Upload
echo "--> Urcare arhiva pe Azure..."
az webapp deployment source config-zip --resource-group $RESOURCE_GROUP --name $WEB_APP_NAME --src deploy.zip

echo "=========================================="
echo "DEPLOY REUSIT!"
echo "Testeaza aplicatia aici:"
echo "Endpoint Info:   https://$WEB_APP_NAME.azurewebsites.net/info"
echo "Endpoint Prompt: https://$WEB_APP_NAME.azurewebsites.net/prompt"
echo "=========================================="