@description('Name of the key vault.')
param name string

@description('Azure region for the key vault.')
param location string = resourceGroup().location

@description('Pricing tier for the key vault.')
param sku string = 'standard'

@description('Enable Azure RBAC for data-plane authorization instead of access policies.')
param enableRbacAuthorization bool = true

@description('Number of days to retain soft-deleted vaults and secrets.')
param softDeleteRetentionInDays int = 90

@description('Enable purge protection to prevent permanent deletion during the retention period.')
param enablePurgeProtection bool = true

@description('Allow public network access to the vault. Defaults to Disabled for a secure baseline.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Disabled'

@description('Resource tags.')
param tags object = {}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: sku
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: enableRbacAuthorization
    enableSoftDelete: true
    softDeleteRetentionInDays: softDeleteRetentionInDays
    enablePurgeProtection: enablePurgeProtection ? true : null
    publicNetworkAccess: publicNetworkAccess
  }
}

@description('Resource ID of the key vault.')
output id string = keyVault.id

@description('Name of the key vault.')
output name string = keyVault.name

@description('URI of the key vault for data-plane access.')
output vaultUri string = keyVault.properties.vaultUri
