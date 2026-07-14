@description('Name of the parent SQL logical server.')
param sqlServerName string

@description('Name of the database.')
param name string

@description('Azure region for the database.')
param location string = resourceGroup().location

@description('SKU name for the database, for example S0.')
param skuName string = 'S0'

@description('SKU tier for the database.')
param skuTier string = 'Standard'

@description('Maximum database size in bytes.')
param maxSizeBytes int = 268435456000

@description('Resource tags.')
param tags object = {}

resource sqlServer 'Microsoft.Sql/servers@2021-11-01' existing = {
  name: sqlServerName
}

resource database 'Microsoft.Sql/servers/databases@2021-11-01' = {
  parent: sqlServer
  name: name
  location: location
  tags: tags
  sku: {
    name: skuName
    tier: skuTier
  }
  properties: {
    maxSizeBytes: maxSizeBytes
  }
}

@description('Resource ID of the database.')
output id string = database.id

@description('Name of the database.')
output name string = database.name
