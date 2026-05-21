@description('Name of the Azure SQL logical server hosting the database.')
param sqlServerName string

@description('Name of the Azure SQL database.')
param name string

@description('Azure region for the Azure SQL database.')
param location string

@description('SKU name for the Azure SQL database.')
param skuName string = 'Basic'

@description('SKU tier for the Azure SQL database.')
param skuTier string = 'Basic'

@description('Maximum size in bytes for the Azure SQL database.')
param maxSizeBytes int = 2147483648

@description('Tags applied to the Azure SQL database.')
param tags object = {}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2023-08-01-preview' = {
  name: '${sqlServerName}/${name}'
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

@description('Resource ID of the Azure SQL database.')
output id string = sqlDatabase.id

@description('Name of the Azure SQL database.')
output name string = sqlDatabase.name
