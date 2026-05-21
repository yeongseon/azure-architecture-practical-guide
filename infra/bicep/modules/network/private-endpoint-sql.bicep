@description('Name of the private endpoint.')
param name string

@description('Azure region for the private endpoint.')
param location string

@description('Resource ID of the subnet hosting the private endpoint.')
param subnetId string

@description('Resource ID of the Azure SQL logical server connected to the private endpoint.')
param sqlServerId string

@description('Resource ID of the private DNS zone for Azure SQL.')
param privateDnsZoneId string

@description('Tags applied to the private endpoint.')
param tags object = {}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2024-01-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${name}-sql'
        properties: {
          privateLinkServiceId: sqlServerId
          groupIds: [
            'sqlServer'
          ]
        }
      }
    ]
  }
}

resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-01-01' = {
  parent: privateEndpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'sql-dns-zone'
        properties: {
          privateDnsZoneId: privateDnsZoneId
        }
      }
    ]
  }
}

@description('Resource ID of the private endpoint.')
output id string = privateEndpoint.id

@description('Name of the private endpoint.')
output name string = privateEndpoint.name

@description('Resource ID of the network interface created for the private endpoint.')
output networkInterfaceId string = privateEndpoint.properties.networkInterfaces[0].id
