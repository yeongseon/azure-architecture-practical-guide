@description('Name of the web app.')
param name string

@description('Azure region for the web app.')
param location string = resourceGroup().location

@description('Resource ID of the App Service plan hosting this app.')
param appServicePlanId string

@description('Linux runtime stack, for example DOTNETCORE|8.0 or NODE|20-lts.')
param linuxFxVersion string = 'DOTNETCORE|8.0'

@description('Application Insights connection string. Empty omits the setting.')
param appInsightsConnectionString string = ''

@description('Application Insights instrumentation key. Empty omits the setting.')
param appInsightsInstrumentationKey string = ''

@description('Additional application settings as name/value pairs.')
param additionalAppSettings array = []

@description('Resource tags.')
param tags object = {}

var appInsightsSettings = concat(
  empty(appInsightsConnectionString) ? [] : [
    {
      name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
      value: appInsightsConnectionString
    }
  ],
  empty(appInsightsInstrumentationKey) ? [] : [
    {
      name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
      value: appInsightsInstrumentationKey
    }
  ]
)

resource webApp 'Microsoft.Web/sites@2023-12-01' = {
  name: name
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
      appSettings: concat(appInsightsSettings, additionalAppSettings)
    }
  }
}

@description('Resource ID of the web app.')
output id string = webApp.id

@description('Name of the web app.')
output name string = webApp.name

@description('Default host name of the web app.')
output defaultHostName string = webApp.properties.defaultHostName

@description('Principal ID of the system-assigned managed identity.')
output principalId string = webApp.identity.principalId
