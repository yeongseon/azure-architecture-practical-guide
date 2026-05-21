@description('Name of the Azure SQL logical server.')
param name string

@description('Azure region for the Azure SQL logical server.')
param location string

@description('Administrator login name for the Azure SQL logical server.')
param administratorLogin string

@description('Administrator login password for the Azure SQL logical server.')
@secure()
param administratorLoginPassword string

@description('Enables Microsoft Entra-only administrator configuration.')
param enableAadAdminOnly bool = false

@description('Display name of the Microsoft Entra administrator.')
param aadAdminLogin string = ''

@description('Object ID of the Microsoft Entra administrator.')
param aadAdminSid string = ''

@description('Tenant ID of the Microsoft Entra administrator.')
param aadAdminTenantId string = ''

@description('Minimum TLS version allowed for Azure SQL connections.')
param minTlsVersion string = '1.2'

@description('Public network access setting for the Azure SQL logical server.')
@allowed([
  'Disabled'
  'Enabled'
])
param publicNetworkAccess string = 'Enabled'

@description('Tags applied to the Azure SQL logical server.')
param tags object = {}

@description('Allows Azure services and resources to access this server via a firewall rule.')
param allowAzureServices bool = false

resource sqlServer 'Microsoft.Sql/servers@2023-08-01-preview' = {
  name: name
  location: location
  tags: tags
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    version: '12.0'
    minimalTlsVersion: minTlsVersion
    publicNetworkAccess: publicNetworkAccess
  }
}

resource aadAdministrator 'Microsoft.Sql/servers/administrators@2023-08-01-preview' = if (enableAadAdminOnly) {
  parent: sqlServer
  name: 'ActiveDirectory'
  properties: {
    administratorType: 'ActiveDirectory'
    login: aadAdminLogin
    sid: aadAdminSid
    tenantId: aadAdminTenantId
  }
}

resource aadOnlyAuthentication 'Microsoft.Sql/servers/azureADOnlyAuthentications@2023-08-01-preview' = if (enableAadAdminOnly) {
  parent: sqlServer
  name: 'Default'
  properties: {
    azureADOnlyAuthentication: true
  }
}

resource allowAzureServicesFirewallRule 'Microsoft.Sql/servers/firewallRules@2023-08-01-preview' = if (allowAzureServices) {
  parent: sqlServer
  name: 'AllowAllWindowsAzureIps'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

@description('Resource ID of the Azure SQL logical server.')
output id string = sqlServer.id

@description('Name of the Azure SQL logical server.')
output name string = sqlServer.name

@description('Fully qualified domain name of the Azure SQL logical server.')
output fullyQualifiedDomainName string = sqlServer.properties.fullyQualifiedDomainName
