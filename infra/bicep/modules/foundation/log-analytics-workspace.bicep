@description('Name of the Log Analytics workspace.')
param name string

@description('Azure region for the workspace.')
param location string = resourceGroup().location

@description('Pricing tier for the workspace.')
param sku string = 'PerGB2018'

@description('Data retention in days.')
param retentionInDays int = 30

@description('Resource tags.')
param tags object = {}

resource workspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    sku: {
      name: sku
    }
    retentionInDays: retentionInDays
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}

@description('Resource ID of the Log Analytics workspace.')
output id string = workspace.id

@description('Name of the Log Analytics workspace.')
output name string = workspace.name

@description('Customer (workspace) ID used by data sources.')
output customerId string = workspace.properties.customerId
