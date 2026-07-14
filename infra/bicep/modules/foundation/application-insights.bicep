@description('Name of the Application Insights component.')
param name string

@description('Azure region for the component.')
param location string = resourceGroup().location

@description('Resource ID of the Log Analytics workspace backing this component.')
param workspaceResourceId string

@description('Application type.')
param applicationType string = 'web'

@description('Resource tags.')
param tags object = {}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  tags: tags
  kind: applicationType
  properties: {
    Application_Type: applicationType
    WorkspaceResourceId: workspaceResourceId
    IngestionMode: 'LogAnalytics'
  }
}

@description('Resource ID of the Application Insights component.')
output id string = appInsights.id

@description('Name of the Application Insights component.')
output name string = appInsights.name

@description('Instrumentation key for the component.')
output instrumentationKey string = appInsights.properties.InstrumentationKey

@description('Connection string for the component.')
output connectionString string = appInsights.properties.ConnectionString
