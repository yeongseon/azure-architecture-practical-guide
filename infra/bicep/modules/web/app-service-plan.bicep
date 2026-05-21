@description('Name of the App Service plan.')
param name string

@description('Azure region for the App Service plan.')
param location string

@description('SKU name for the App Service plan.')
param skuName string = 'B1'

@description('SKU tier for the App Service plan.')
param skuTier string = 'Basic'

@description('Kind for the App Service plan.')
param kind string = 'linux'

@description('Specifies whether the App Service plan uses Linux workers.')
param reserved bool = true

@description('Tags applied to the App Service plan.')
param tags object = {}

resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: name
  location: location
  kind: kind
  tags: tags
  sku: {
    name: skuName
    tier: skuTier
  }
  properties: {
    reserved: reserved
  }
}

@description('Resource ID of the App Service plan.')
output id string = appServicePlan.id

@description('Name of the App Service plan.')
output name string = appServicePlan.name
