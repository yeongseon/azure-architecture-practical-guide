@description('Name of the Application Insights component.')
param name string

@description('Azure region for the Application Insights component.')
param location string

@description('Resource ID of the Log Analytics workspace linked to Application Insights.')
param logAnalyticsWorkspaceId string

@description('Tags applied to the Application Insights component.')
param tags object = {}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  kind: 'web'
  tags: tags
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspaceId
  }
}

@description('Resource ID of the Application Insights component.')
output id string = applicationInsights.id

@description('Name of the Application Insights component.')
output name string = applicationInsights.name

@description('Instrumentation key for the Application Insights component.')
output instrumentationKey string = applicationInsights.properties.InstrumentationKey

@description('Connection string for the Application Insights component.')
output connectionString string = applicationInsights.properties.ConnectionString
