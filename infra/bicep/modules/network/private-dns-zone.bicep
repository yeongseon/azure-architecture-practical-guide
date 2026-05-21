@description('Name of the private DNS zone.')
param name string

@description('Resource ID of the virtual network linked to the private DNS zone.')
param virtualNetworkId string

@description('Specifies whether auto-registration is enabled for the virtual network link.')
param registrationEnabled bool = false

@description('Tags applied to the private DNS zone.')
param tags object = {}

var virtualNetworkName = last(split(virtualNetworkId, '/'))

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: name
  location: 'global'
  tags: tags
}

resource virtualNetworkLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  parent: privateDnsZone
  name: '${virtualNetworkName}-link'
  location: 'global'
  properties: {
    registrationEnabled: registrationEnabled
    virtualNetwork: {
      id: virtualNetworkId
    }
  }
}

@description('Resource ID of the private DNS zone.')
output id string = privateDnsZone.id

@description('Name of the private DNS zone.')
output name string = privateDnsZone.name
