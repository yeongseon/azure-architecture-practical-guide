type appSetting = {
  name: string
  value: string
}

type connectionStringSetting = {
  name: string
  connectionString: string
  type: 'ApiHub' | 'Custom' | 'DocDb' | 'EventHub' | 'MySql' | 'NotificationHub' | 'PostgreSQL' | 'RedisCache' | 'SQLAzure' | 'SQLServer' | 'ServiceBus'
}

@description('Name of the web app.')
param name string

@description('Azure region for the web app.')
param location string

@description('Resource ID of the App Service plan hosting the web app.')
param appServicePlanId string

@description('Runtime stack for the Linux web app.')
param linuxFxVersion string = 'DOTNETCORE|8.0'

@description('Application settings for the web app.')
param appSettings appSetting[] = []

@description('Connection strings for the web app.')
param connectionStrings connectionStringSetting[] = []

@description('Optional Application Insights connection string injected into app settings.')
param appInsightsConnectionString string = ''

@description('Resource ID of the subnet for VNet integration. Leave empty to skip VNet integration.')
param virtualNetworkSubnetId string = ''

@description('Tags applied to the web app.')
param tags object = {}

var combinedAppSettings = concat(
  appSettings,
  empty(appInsightsConnectionString)
    ? []
    : [
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsightsConnectionString
        }
      ]
)

resource webApp 'Microsoft.Web/sites@2023-12-01' = {
  name: name
  location: location
  kind: 'app,linux'
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
    virtualNetworkSubnetId: empty(virtualNetworkSubnetId) ? null : virtualNetworkSubnetId
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      minTlsVersion: '1.2'
      ftpsState: 'Disabled'
      appSettings: [for setting in combinedAppSettings: {
        name: setting.name
        value: setting.value
      }]
      connectionStrings: [for cs in connectionStrings: {
        name: cs.name
        connectionString: cs.connectionString
        type: cs.type
      }]
    }
  }
}

@description('Resource ID of the web app.')
output id string = webApp.id

@description('Name of the web app.')
output name string = webApp.name

@description('Default hostname of the web app.')
output defaultHostName string = webApp.properties.defaultHostName

@description('Principal ID of the system-assigned managed identity.')
output principalId string = webApp.identity.principalId
