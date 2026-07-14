@description('Name of the App Service plan.')
param name string

@description('Azure region for the plan.')
param location string = resourceGroup().location

@description('SKU name for the plan, for example P1v3.')
param skuName string = 'P1v3'

@description('SKU tier for the plan.')
param skuTier string = 'PremiumV3'

@description('Number of worker instances.')
param capacity int = 1

@description('Host the plan on Linux.')
param linux bool = true

@description('Resource tags.')
param tags object = {}

resource plan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: skuName
    tier: skuTier
    capacity: capacity
  }
  kind: linux ? 'linux' : 'app'
  properties: {
    reserved: linux
  }
}

@description('Resource ID of the App Service plan.')
output id string = plan.id

@description('Name of the App Service plan.')
output name string = plan.name
