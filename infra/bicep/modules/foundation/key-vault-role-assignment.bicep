@description('Name of the existing Key Vault to scope the role assignment to.')
param keyVaultName string

@description('Principal (object) ID that receives the role assignment.')
param principalId string

@description('Resource ID of the role definition to assign.')
param roleDefinitionId string

@description('Type of principal receiving the assignment.')
@allowed([
  'User'
  'Group'
  'ServicePrincipal'
  'ForeignGroup'
  'Device'
])
param principalType string = 'ServicePrincipal'

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: keyVault
  name: guid(keyVault.id, principalId, roleDefinitionId)
  properties: {
    principalId: principalId
    roleDefinitionId: roleDefinitionId
    principalType: principalType
  }
}

@description('Resource ID of the role assignment.')
output id string = roleAssignment.id

@description('Name (GUID) of the role assignment.')
output name string = roleAssignment.name
