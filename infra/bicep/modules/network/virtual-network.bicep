@description('Name of the virtual network.')
param name string

@description('Azure region for the virtual network.')
param location string = resourceGroup().location

@description('Address prefixes for the virtual network.')
param addressPrefixes array = [
  '10.0.0.0/16'
]

@description('Subnets to create. Each item requires name and addressPrefix.')
param subnets array = []

@description('Resource tags.')
param tags object = {}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
    subnets: [for subnet in subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.addressPrefix
        privateEndpointNetworkPolicies: subnet.?privateEndpointNetworkPolicies ?? 'Disabled'
        delegations: subnet.?delegation != null ? [
          {
            name: 'delegation'
            properties: {
              serviceName: subnet.delegation
            }
          }
        ] : []
      }
    }]
  }
}

@description('Resource ID of the virtual network.')
output id string = virtualNetwork.id

@description('Name of the virtual network.')
output name string = virtualNetwork.name

@description('Resource IDs of the created subnets.')
output subnetIds array = [for (subnet, i) in subnets: virtualNetwork.properties.subnets[i].id]
