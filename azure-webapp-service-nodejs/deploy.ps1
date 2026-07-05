param(
    [string]$SubscriptionId = '7ebbb0f9-29e5-498d-bc3b-63590a23bf88',
    [string]$ResourceGroupName = 'dev-rg-warehouse-service',
    [string]$Location = 'eastus',
    [string]$PlanName = 'dev-warehouseapp-plan',
    [string]$WebAppName = 'dev-warehouseapp-service'
)

$ErrorActionPreference = 'Stop'

Write-Host 'Setting subscription...'
az account set --subscription $SubscriptionId

Write-Host 'Creating resource group...'
az group create --name $ResourceGroupName --location $Location

Write-Host 'Creating App Service plan...'
az appservice plan create --name $PlanName --resource-group $ResourceGroupName --sku B1 --is-linux --location $Location

Write-Host 'Creating Web App...'
az webapp create --resource-group $ResourceGroupName --plan $PlanName --name $WebAppName --runtime 'NODE|22-lts'

Write-Host 'Deploying application code...'
Set-Location "$PSScriptRoot/app"
npm install
if (Test-Path app.zip) { Remove-Item app.zip -Force }
Compress-Archive -Path .\* -DestinationPath app.zip -Force
az webapp deployment source config-zip --resource-group $ResourceGroupName --name $WebAppName --src app.zip

Write-Host 'Deployment complete.'
Write-Host "App URL: https://$WebAppName.azurewebsites.net"
