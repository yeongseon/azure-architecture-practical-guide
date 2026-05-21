type appSetting = {
  name: string
  value: string
}

@description('Name of the parent web app.')
param webAppName string

@description('Name of the deployment slot.')
param slotName string = 'staging'

@description('Azure region for the deployment slot.')
param location string

@description('Resource ID of the App Service plan hosting the slot.')
param appServicePlanId string

@description('Runtime stack for the Linux deployment slot.')
param linuxFxVersion string = 'DOTNETCORE|8.0'

@description('Application settings for the deployment slot.')
param appSettings appSetting[] = []

@description('Tags applied to the deployment slot.')
param tags object = {}

resource webApp 'Microsoft.Web/sites@2023-12-01' existing = {
  name: webAppName
}

resource slot 'Microsoft.Web/sites/slots@2023-12-01' = {
  parent: webApp
  name: slotName
  location: location
  kind: 'app,linux'
  tags: tags
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      minTlsVersion: '1.2'
      ftpsState: 'Disabled'
      appSettings: [for setting in appSettings: {
        name: setting.name
        value: setting.value
      }]
    }
  }
}

@description('Resource ID of the deployment slot.')
output id string = slot.id

@description('Name of the deployment slot.')
output name string = slot.name

@description('Default hostname of the deployment slot.')
output defaultHostName string = slot.properties.defaultHostName
