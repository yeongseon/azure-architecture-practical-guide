@description('Object ID of the principal receiving the role assignment.')
param principalId string

@description('Resource ID of the role definition to assign.')
param roleDefinitionId string

@description('Type of principal receiving the role assignment.')
@allowed([
  'Device'
  'ForeignGroup'
  'Group'
  'ServicePrincipal'
  'User'
])
param principalType string = 'ServicePrincipal'

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, principalId, roleDefinitionId)
  properties: {
    principalId: principalId
    principalType: principalType
    roleDefinitionId: roleDefinitionId
  }
}

@description('Resource ID of the role assignment.')
output id string = roleAssignment.id
