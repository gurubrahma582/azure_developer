param(
    [string]$SubscriptionId = $env:SUBSCRIPTION_ID,
    [string]$ResourceGroupName = $env:RESOURCE_GROUP_NAME,
    [string]$Location = $env:LOCATION,
    [string]$PlanName = $env:PLAN_NAME,
    [string]$WebAppName = $env:WEB_APP_NAME,
    [string]$Environment = $null
)

$ErrorActionPreference = 'Stop'

Write-Host 'Resolving parameters...'
# If an environment is supplied (e.g., 'dev','qa','prod'), try to read its Bicep parameters file
if ($Environment) {
    $paramFile = Join-Path $PSScriptRoot "infra\parameters\$($Environment).bicepparam"
    if (Test-Path $paramFile) {
        Write-Host "Loading environment parameters from $paramFile"
        $content = Get-Content $paramFile -Raw
        $m = [regex]::Match($content, "param\s+resourceGroupName\s*=\s*'([^']+)'")
        if ($m.Success) { $ResourceGroupName = $m.Groups[1].Value }
        $m = [regex]::Match($content, "param\s+planName\s*=\s*'([^']+)'")
        if ($m.Success) { $PlanName = $m.Groups[1].Value }
        $m = [regex]::Match($content, "param\s+webAppName\s*=\s*'([^']+)'")
        if ($m.Success) { $WebAppName = $m.Groups[1].Value }
        $m = [regex]::Match($content, "param\s+location\s*=\s*'([^']+)'")
        if ($m.Success) { $Location = $m.Groups[1].Value }
        $m = [regex]::Match($content, "param\s+appName\s*=\s*'([^']+)'")
        if ($m.Success -and -not $WebAppName) { $WebAppName = $m.Groups[1].Value }
    } else {
        Write-Host "Environment param file not found: $paramFile"
    }
}
# Populate from environment / CLI if not provided
if (-not $SubscriptionId) {
    $SubscriptionId = $env:SUBSCRIPTION_ID
}
if (-not $SubscriptionId) {
    try { $SubscriptionId = (az account show --query id -o tsv) } catch { }
}
if (-not $SubscriptionId) { Write-Error 'SubscriptionId not set. Provide -SubscriptionId or set $env:SUBSCRIPTION_ID'; exit 1 }

if (-not $Location) { $Location = 'eastus' }

if (-not $WebAppName) { Write-Error 'WebAppName not set. Provide -WebAppName or set $env:WEB_APP_NAME'; exit 1 }

if (-not $PlanName) { $PlanName = "$WebAppName-plan" }

if (-not $ResourceGroupName) { Write-Error 'ResourceGroupName not set. Provide -ResourceGroupName or set $env:RESOURCE_GROUP_NAME'; exit 1 }

Write-Host "Using Subscription: $SubscriptionId"
az account set --subscription $SubscriptionId

# Pre-flight permission checks
Write-Host 'Checking resource group visibility and permissions...'
$rgCheckOutput = & az group show --name $ResourceGroupName 2>&1
if ($LASTEXITCODE -ne 0) {
    if ($rgCheckOutput -match 'AuthorizationFailed') {
        Write-Error "AuthorizationFailed: your principal cannot read/create resource groups in subscription $SubscriptionId.\nPlease ask the subscription or resource-group owner to grant you the Contributor role on the subscription or on /resourceGroups/$ResourceGroupName."
        exit 1
    }
    # If resource group doesn't exist, try a harmless list to detect permission to create
    Write-Host "Resource group '$ResourceGroupName' not found or inaccessible. Verifying create permission..."
    $testCreateOut = & az group create --name $ResourceGroupName --location $Location --query name -o tsv 2>&1
    if ($LASTEXITCODE -ne 0) {
        if ($testCreateOut -match 'AuthorizationFailed') {
            Write-Error "AuthorizationFailed: cannot create resource group '$ResourceGroupName'. Ask owner to grant Contributor role on subscription or resource group."
            exit 1
        }
        Write-Host "Info: could not create resource group (it may already exist or other error): $testCreateOut"
    } else {
        Write-Host "Resource group '$ResourceGroupName' created (pre-check)"
    }
} else {
    Write-Host "Resource group '$ResourceGroupName' exists and is readable."
}

Write-Host 'Creating resource group (if not exists)...'
az group create --name $ResourceGroupName --location $Location | Out-Null

Write-Host 'Creating App Service plan...'
$planCreateOut = & az appservice plan create --name $PlanName --resource-group $ResourceGroupName --sku B1 --is-linux --location $Location 2>&1
if ($LASTEXITCODE -ne 0) {
    if ($planCreateOut -match 'AuthorizationFailed') {
        Write-Error "AuthorizationFailed: cannot create App Service plan '$PlanName'. Ensure you have 'Microsoft.Web/serverfarms/write' permission (Contributor role)."
        exit 1
    }
    else {
        Write-Error "Failed to create App Service plan: $planCreateOut"
        exit 1
    }
}

Write-Host 'Creating Web App...'
# Avoid PowerShell parsing of '|' by passing arguments as an array to Start-Process
$args = @('webapp','create','--resource-group',$ResourceGroupName,'--plan',$PlanName,'--name',$WebAppName,'--runtime','NODE|22-lts')
$proc = Start-Process -FilePath 'az' -ArgumentList $args -NoNewWindow -Wait -PassThru -RedirectStandardError STDERR.txt -RedirectStandardOutput STDOUT.txt
if ($proc.ExitCode -ne 0) {
    $out = Get-Content STDOUT.txt -Raw
    $err = Get-Content STDERR.txt -Raw
    if ($err -match 'AuthorizationFailed') {
        Write-Error "AuthorizationFailed: cannot create Web App '$WebAppName'. Ensure you have required permissions (Contributor or Web Contributor on the scope).\n$err"
        Remove-Item STDOUT.txt,STDERr.txt -ErrorAction SilentlyContinue
        exit 1
    }
    else {
        Write-Error "az webapp create failed: $err"
        Remove-Item STDOUT.txt,STDERr.txt -ErrorAction SilentlyContinue
        exit 1
    }
}
Remove-Item STDOUT.txt,STDERr.txt -ErrorAction SilentlyContinue

Write-Host 'Deploying application code...'
Push-Location
Set-Location (Join-Path $PSScriptRoot 'app')
npm install
if (Test-Path app.zip) { Remove-Item app.zip -Force }
Compress-Archive -Path .\* -DestinationPath app.zip -Force
az webapp deployment source config-zip --resource-group $ResourceGroupName --name $WebAppName --src app.zip

Pop-Location
Write-Host 'Deployment complete.'
Write-Host "App URL: https://$WebAppName.azurewebsites.net"
