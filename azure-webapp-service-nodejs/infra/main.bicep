param location string = 'eastus'
param appName string = 'dev-warehouseapp-service'
param resourceGroupName string = resourceGroup().name
param planName string = '${appName}-plan'
param webAppName string = appName
param skuName string = 'B1'
param skuCapacity int = 1

var linuxFxVersion = 'NODE|22-lts'

resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: planName
  location: location
  sku: {
    name: skuName
    capacity: skuCapacity
  }
  kind: 'linux'
  tags: {
    resourceGroupName: resourceGroupName
  }
  properties: {
    reserved: true
  }
}

resource webApp 'Microsoft.Web/sites@2023-12-01' = {
  name: webAppName
  location: location
  kind: 'app,linux'
  tags: {
    resourceGroupName: resourceGroupName
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      appSettings: [
        {
          name: 'WEBSITES_PORT'
          value: '3000'
        }
        {
          name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
          value: 'true'
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~22'
        }
      ]
      alwaysOn: true
    }
  }
}

