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

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, principalId, roleDefinitionId)
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
