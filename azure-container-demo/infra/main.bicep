@description('Container Group Name')
param containerGroupName string = 'aci-demo'

@description('Azure Region')
param location string = resourceGroup().location

@description('Container Image')
param image string = 'mcr.microsoft.com/azuredocs/aci-helloworld'

@description('Container Port')
param port int = 80

@description('CPU Cores')
param cpu int = 1

@description('Memory in GB')
param memory int = 2