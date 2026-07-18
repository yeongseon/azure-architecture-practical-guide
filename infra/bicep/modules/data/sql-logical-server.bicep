@description('Name of the SQL logical server.')
param name string

@description('Azure region for the server.')
param location string = resourceGroup().location

@description('Administrator login name.')
param administratorLogin string

@description('Administrator login password.')
@secure()
param administratorLoginPassword string

@description('Allow public network access to the server.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Disabled'

@description('Resource tags.')
param tags object = {}

resource sqlServer 'Microsoft.Sql/servers@2021-11-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    version: '12.0'
    minimalTlsVersion: '1.2'
    publicNetworkAccess: publicNetworkAccess
  }
}

@description('Resource ID of the SQL logical server.')
output id string = sqlServer.id

@description('Name of the SQL logical server.')
output name string = sqlServer.name

@description('Fully qualified domain name of the server.')
output fullyQualifiedDomainName string = sqlServer.properties.fullyQualifiedDomainName
