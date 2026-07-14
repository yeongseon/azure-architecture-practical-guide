@description('Name of the primary SQL logical server.')
param primaryServerName string

@description('Name of the failover group.')
param name string

@description('Resource ID of the partner (secondary) SQL logical server.')
param partnerServerId string

@description('Resource IDs of the databases to include in the failover group.')
param databaseIds array

@description('Grace period in minutes before automatic failover with data loss.')
param gracePeriodMinutes int = 60

resource primaryServer 'Microsoft.Sql/servers@2023-08-01-preview' existing = {
  name: primaryServerName
}

resource failoverGroup 'Microsoft.Sql/servers/failoverGroups@2023-08-01-preview' = {
  parent: primaryServer
  name: name
  properties: {
    readWriteEndpoint: {
      failoverPolicy: 'Automatic'
      failoverWithDataLossGracePeriodMinutes: gracePeriodMinutes
    }
    partnerServers: [
      {
        id: partnerServerId
      }
    ]
    databases: databaseIds
  }
}

@description('Resource ID of the failover group.')
output id string = failoverGroup.id

@description('Name of the failover group.')
output name string = failoverGroup.name
