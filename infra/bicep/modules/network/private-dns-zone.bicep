@description('Name of the private DNS zone, for example privatelink.database.windows.net.')
param name string

@description('Virtual networks to link to this zone. Each item requires name and virtualNetworkId.')
param virtualNetworkLinks array = []

@description('Resource tags.')
param tags object = {}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: name
  location: 'global'
  tags: tags
}

resource links 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [for link in virtualNetworkLinks: {
  parent: privateDnsZone
  name: link.name
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: link.virtualNetworkId
    }
  }
}]

@description('Resource ID of the private DNS zone.')
output id string = privateDnsZone.id

@description('Name of the private DNS zone.')
output name string = privateDnsZone.name
