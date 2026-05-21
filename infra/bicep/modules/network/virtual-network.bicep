type subnetDelegation = {
  name: string
  serviceName: string
}

type subnetDefinition = {
  name: string
  addressPrefix: string
  delegations: subnetDelegation[]?
  serviceEndpoints: string[]?
}

@description('Name of the virtual network.')
param name string

@description('Azure region for the virtual network.')
param location string

@description('Address space prefix for the virtual network.')
param addressPrefix string = '10.0.0.0/16'

@description('Subnet definitions for the virtual network.')
param subnets subnetDefinition[]

@description('Tags applied to the virtual network.')
param tags object = {}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [for subnet in subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.addressPrefix
        delegations: map(subnet.?delegations ?? [], delegation => {
          name: delegation.name
          properties: {
            serviceName: delegation.serviceName
          }
        })
        serviceEndpoints: map(subnet.?serviceEndpoints ?? [], serviceEndpoint => {
          service: serviceEndpoint
        })
      }
    }]
  }
}

@description('Resource ID of the virtual network.')
output id string = virtualNetwork.id

@description('Name of the virtual network.')
output name string = virtualNetwork.name

@description('Object containing subnet names mapped to subnet resource IDs.')
output subnetIds object = reduce(subnets, {}, (result, subnet) => union(result, {
  '${subnet.name}': resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetwork.name, subnet.name)
}))
