@description('Name of the Azure SQL failover group.')
param name string

@description('Name of the primary Azure SQL logical server.')
param sqlServerName string

@description('Resource ID of the partner Azure SQL logical server.')
param partnerServerId string

@description('Resource IDs of databases included in the failover group.')
param databaseIds array

@description('Read-write failover policy mode for the failover group.')
@allowed([
  'Automatic'
  'Manual'
])
param readWriteFailoverPolicyMode string = 'Automatic'

@description('Grace period in minutes before automatic failover with data loss.')
param failoverGracePeriodMinutes int = 60

resource failoverGroup 'Microsoft.Sql/servers/failoverGroups@2023-08-01-preview' = {
  name: '${sqlServerName}/${name}'
  properties: {
    databases: databaseIds
    partnerServers: [
      {
        id: partnerServerId
      }
    ]
    readWriteEndpoint: {
      failoverPolicy: readWriteFailoverPolicyMode
      failoverWithDataLossGracePeriodMinutes: failoverGracePeriodMinutes
    }
    readOnlyEndpoint: {
      failoverPolicy: 'Disabled'
    }
  }
}

@description('Resource ID of the Azure SQL failover group.')
output id string = failoverGroup.id

@description('Name of the Azure SQL failover group.')
output name string = failoverGroup.name

@description('Read-write endpoint configuration for the failover group.')
output readWriteEndpoint object = failoverGroup.properties.readWriteEndpoint

@description('Read-only endpoint configuration for the failover group.')
output readOnlyEndpoint object = failoverGroup.properties.readOnlyEndpoint
