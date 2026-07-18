@description('Name of the private endpoint.')
param name string

@description('Azure region for the private endpoint.')
param location string = resourceGroup().location

@description('Resource ID of the subnet hosting the private endpoint.')
param subnetId string

@description('Resource ID of the target web app.')
param webAppId string

@description('Resource ID of the private DNS zone for the web app. Empty skips DNS integration.')
param privateDnsZoneId string = ''

@description('Resource tags.')
param tags object = {}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-11-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${name}-connection'
        properties: {
          privateLinkServiceId: webAppId
          groupIds: [
            'sites'
          ]
        }
      }
    ]
  }
}

resource dnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-11-01' = if (!empty(privateDnsZoneId)) {
  parent: privateEndpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'sites'
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
