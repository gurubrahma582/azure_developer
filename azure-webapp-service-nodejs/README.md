# Azure Web App Service (Node.js)

This sample deploys a Node.js Express app to Azure App Service using Infrastructure as Code with Bicep.

## Prerequisites

- Azure CLI installed and logged in
- Azure subscription
- Node.js 22+

## Deploy

For a real-world setup, use separate environments for dev, QA, and prod. A good pattern is:

- Terraform creates the resource group and shared platform resources.
- Bicep deploys the App Service plan and Web App for each environment.
- Each environment uses its own parameter file.

### Environment-based deployment

Use these commands for each environment:

```bash
az deployment group create \
  --resource-group <resource-group-name> \
  --template-file infra/main.bicep \
  --parameters @infra/parameters/dev.bicepparam
```

```bash
az deployment group create \
  --resource-group <resource-group-name> \
  --template-file infra/main.bicep \
  --parameters @infra/parameters/qa.bicepparam
```

```bash
az deployment group create \
  --resource-group <resource-group-name> \
  --template-file infra/main.bicep \
  --parameters @infra/parameters/prod.bicepparam
```

### Full deployment commands

If you are already logged in from VS Code, you can use your active Azure subscription directly.

```bash
# Bash (Linux / macOS / Git Bash)
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
az account set --subscription "$SUBSCRIPTION_ID"
az group create --name dev-rg-warehouse-05072026 --location eastus
az appservice plan create --name devwarehouseappplan --resource-group dev-rg-warehouse-05072026 --sku B1 --is-linux --location eastus
az webapp create --resource-group dev-rg-warehouse-05072026 --plan devwarehouseappplan --name dev-warehouseapp-05072026 --runtime "NODE|22-lts"
cd app
npm install
zip -r app.zip .
az webapp deployment source config-zip --resource-group dev-rg-warehouse-05072026 --name dev-warehouseapp-05072026 --src app.zip
az webapp show --resource-group dev-rg-warehouse-05072026 --name dev-warehouseapp-05072026 --query defaultHostName -o tsv
```

```powershell
# PowerShell (Windows PowerShell / PowerShell Core)
$env:SUBSCRIPTION_ID = (az account show --query id -o tsv)
az account set --subscription $env:SUBSCRIPTION_ID
az group create --name dev-rg-warehouse-05072026 --location eastus
az appservice plan create --name devwarehouseappplan --resource-group dev-rg-warehouse-05072026 --sku B1 --is-linux --location eastus
az webapp create --resource-group dev-rg-warehouse-05072026 --plan devwarehouseappplan --name dev-warehouseapp-05072026 --runtime "NODE|22-lts"
Set-Location app
npm install
Compress-Archive -Path * -DestinationPath app.zip -Force
az webapp deployment source config-zip --resource-group dev-rg-warehouse-05072026 --name dev-warehouseapp-05072026 --src app.zip
az webapp show --resource-group dev-rg-warehouse-05072026 --name dev-warehouseapp-05072026 --query defaultHostName -o tsv
```

### Option 1: One-click PowerShell script

Run this from the project folder:

```powershell
./deploy.ps1
```

This single command will create the resource group, App Service plan, Web App, deploy the Node.js app, and print the app URL.

### Option 2: Manual Azure CLI commands

```bash
# Bash (Linux / macOS / Git Bash)
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
az account set --subscription "$SUBSCRIPTION_ID"
az appservice plan create --name devwarehouseappplan --resource-group dev-rg-warehouse-05072026 --sku B1 --is-linux --location eastus
az webapp create --resource-group dev-rg-warehouse-05072026 --plan devwarehouseappplan --name dev-warehouseapp-05072026 --runtime "NODE|22-lts"
```

```powershell
# PowerShell (Windows PowerShell / PowerShell Core)
$env:SUBSCRIPTION_ID = (az account show --query id -o tsv)
az account set --subscription $env:SUBSCRIPTION_ID
az appservice plan create --name devwarehouseappplan --resource-group dev-rg-warehouse-05072026 --sku B1 --is-linux --location eastus
az webapp create --resource-group dev-rg-warehouse-05072026 --plan devwarehouseappplan --name dev-warehouseapp-05072026 --runtime "NODE|22-lts"
```

## Deploy the app code

After the infrastructure is deployed, publish the app from the app folder:

```bash
cd app
npm install
zip -r app.zip .
az webapp deployment source config-zip --resource-group dev-rg-warehouse-05072026 --name dev-warehouseapp-05072026 --src app.zip
```

## Verify

Open the app URL shown in the deployment output or run:

```bash
az webapp show --resource-group dev-rg-warehouse-05072026 --name dev-warehouseapp-05072026 --query defaultHostName -o tsv
```
