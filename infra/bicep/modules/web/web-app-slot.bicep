@description('Name of the parent web app.')
param webAppName string

@description('Name of the deployment slot, for example staging.')
param slotName string = 'staging'

@description('Azure region for the slot.')
param location string = resourceGroup().location

@description('Resource ID of the App Service plan hosting the slot.')
param appServicePlanId string

@description('Linux runtime stack, for example DOTNETCORE|8.0 or NODE|20-lts.')
param linuxFxVersion string = 'DOTNETCORE|8.0'

@description('Application settings as name/value pairs.')
param appSettings array = []

@description('Resource tags.')
param tags object = {}

resource webApp 'Microsoft.Web/sites@2023-12-01' existing = {
  name: webAppName
}

resource slot 'Microsoft.Web/sites/slots@2023-12-01' = {
  parent: webApp
  name: slotName
  location: location
  tags: tags
  kind: 'app,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      appSettings: appSettings
    }
  }
}

@description('Resource ID of the deployment slot.')
output id string = slot.id

@description('Name of the deployment slot.')
output name string = slot.name

@description('Default host name of the slot.')
output defaultHostName string = slot.properties.defaultHostName

@description('Principal ID of the slot system-assigned managed identity.')
output principalId string = slot.identity.principalId
