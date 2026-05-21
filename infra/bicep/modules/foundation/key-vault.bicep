@description('Name of the Azure Key Vault.')
param name string

@description('Azure region for the Azure Key Vault.')
param location string

@description('Microsoft Entra tenant ID for the Azure Key Vault.')
param tenantId string

@description('Enables Azure RBAC authorization for the Azure Key Vault.')
param enableRbacAuthorization bool = true

@description('Enables soft delete for the Azure Key Vault.')
param enableSoftDelete bool = true

@description('Tags applied to the Azure Key Vault.')
param tags object = {}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    tenantId: tenantId
    enableRbacAuthorization: enableRbacAuthorization
    enableSoftDelete: enableSoftDelete
    sku: {
      family: 'A'
      name: 'standard'
    }
  }
}

@description('Resource ID of the Azure Key Vault.')
output id string = keyVault.id

@description('Name of the Azure Key Vault.')
output name string = keyVault.name

@description('URI of the Azure Key Vault.')
output uri string = keyVault.properties.vaultUri
