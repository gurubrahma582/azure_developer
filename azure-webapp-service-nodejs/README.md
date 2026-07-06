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

## Troubleshooting & command log (what I ran for whizlabs)

If you run into failures when creating resources in the Whizlabs lab subscription, here's a concise log of the commands I executed, what failed, and the corrected commands you should run.

1. Subscription / environment variable

Bash (Linux / macOS / Git Bash):

```bash
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
az account set --subscription "$SUBSCRIPTION_ID"
```

PowerShell (Windows PowerShell / PowerShell Core):

```powershell
# Correct: use PowerShell subexpression and set environment variable
$env:SUBSCRIPTION_ID = (az account show --query id -o tsv)
az account set --subscription $env:SUBSCRIPTION_ID

# Print the env var you set
Write-Output $env:SUBSCRIPTION_ID
# Equivalent
echo $env:SUBSCRIPTION_ID
# Show the active subscription id and name from Azure CLI
az account show --query id -o tsv
az account show --query name -o tsv
# List all accounts/subscriptions
az account list -o table
# List resource groups in the active subscription
az group list --subscription $env:SUBSCRIPTION_ID -o table

```

Common mistake (fails in PowerShell):

```powershell
SUBSCRIPTION_ID=$(az account show --query id -o tsv)  # This is Bash-style assignment — causes errors in PowerShell
```

2. Resource group creation — Authorization error

If `az group create` returns AuthorizationFailed, it means your principal does not have the required RBAC at the subscription scope. In the Whizlabs lab this is expected: the lab platform often creates the RG and assigns a lab-specific role to the student account.

To inspect the RG and recent actions:

check every time whizlab rg will change every time : lab-309-2287518-fbb70763 --> validate for below need to replace rg every time sandbox start this only whizlab users

```bash
az group show --name lab-309-2287518-fbb70763 --subscription $env:SUBSCRIPTION_ID -o json

az monitor activity-log list --resource-group lab-309-2287518-fbb70763 --subscription $env:SUBSCRIPTION_ID --max-events 50 -o table
az role assignment list --scope /subscriptions/$env:SUBSCRIPTION_ID/resourceGroups/lab-309-2287518-da9d4ecd -o table
```

3. App Service plan creation (worked)

```bash
az appservice plan create --name dev-warehouse-app-plan --resource-group lab-309-2287518-da9d4ecd --sku B1 --is-linux --location eastus
```

4. Web App creation — PowerShell quoting pitfalls

Problem: PowerShell treats `|` as a pipeline, so passing `--runtime "NODE|22-lts"` directly can make PowerShell try to execute the right-hand side.

Failed attempts (PowerShell reported: `'22-lts' is not recognized as an internal or external command`):

```powershell
az webapp create --resource-group lab-309-2287518-da9d4ecd --plan devwarehouseappplan --name dev-warehouseapp-05072026 --runtime "NODE|22-lts"
az webapp create --resource-group lab-309-2287518-da9d4ecd --plan devwarehouseappplan --name dev-warehouseapp-05072026 --runtime 'NODE|22-lts'
```

Working workaround (PowerShell):

```powershell
az --% webapp create --resource-group lab-309-2287518-da9d4ecd --plan devwarehouseappplan --name dev-warehouseapp-05072026 --runtime "NODE|22-lts"
```

Alternatively, run the webapp create from Bash/Git Bash where the pipe is not interpreted by the shell.

5. Deploying app (example — PowerShell)

```powershell
Set-Location azure-webapp-service-nodejs\app
npm install
Compress-Archive -Path * -DestinationPath app.zip -Force
az webapp deployment source config-zip --resource-group lab-309-2287518-da9d4ecd --name dev-warehouseapp-05072026 --src app.zip
```

6. Helpful checks and refresh

If roles were granted recently, refresh your CLI credentials:

```bash
az account clear
az login
```

Check your effective roles:

```bash
az role assignment list --assignee <your-user-principal-name-or-object-id> --scope /subscriptions/<subscriptionId> -o table
```

If you want, copy these snippets into your `deploy.ps1` or into a local `deploy.sh` and run from the project root. The README has both Bash and PowerShell examples above — use the PowerShell forms when you are in PowerShell.

If you'd like, I can also add a compact `deploy.ps1` that wraps the working PowerShell commands and includes checks/early exits — shall I add that next?

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
