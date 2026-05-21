targetScope = 'resourceGroup'

@description('Azure region for the Stage 2 production baseline deployment.')
param location string

@description('Application name prefix used to derive resource names.')
param appName string

@description('Administrator login name for the Azure SQL logical server.')
param sqlAdminLogin string

@description('Administrator login password for the Azure SQL logical server.')
@secure()
param sqlAdminPassword string

@description('Email address used by the Azure Monitor action group.')
param alertEmail string

@description('SKU name for the App Service plan.')
param skuName string = 'S1'

var uniqueSuffix = toLower(uniqueString(subscription().subscriptionId, resourceGroup().name, appName))
var appNameCompact = toLower(replace(appName, '-', ''))
var logAnalyticsWorkspaceName = '${appName}-law'
var applicationInsightsName = '${appName}-appi'
var appServicePlanName = '${appName}-asp'
var webAppName = '${appName}-web'
var slotName = 'staging'
var sqlServerName = '${take(appNameCompact, 48)}sql${take(uniqueSuffix, 8)}'
var sqlDatabaseName = '${appName}-db'
var keyVaultName = take('${appNameCompact}kv${take(uniqueSuffix, 8)}', 24)
var actionGroupName = '${appName}-ag'
var actionGroupShortName = take('s2${appNameCompact}', 12)
var metricAlertName = '${appName}-http5xx-alert'
var sqlConnectionSecretName = 'SqlConnectionString'
var appServicePlanSkuTier = startsWith(toUpper(skuName), 'S') ? 'Standard' : 'Basic'
var commonTags = {
  architecture: 'practical-journey'
  stage: 'stage-02-production-baseline'
}
var sqlConnectionString = 'Server=tcp:${sqlServer.outputs.fullyQualifiedDomainName},1433;Initial Catalog=${sqlDatabaseName};Persist Security Info=False;User ID=${sqlAdminLogin};Password=${sqlAdminPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'

module logAnalytics '../../modules/foundation/log-analytics-workspace.bicep' = {
  name: 'stage02-log-analytics'
  params: {
    name: logAnalyticsWorkspaceName
    location: location
    retentionInDays: 7
    tags: commonTags
  }
}

module applicationInsights '../../modules/foundation/application-insights.bicep' = {
  name: 'stage02-application-insights'
  params: {
    name: applicationInsightsName
    location: location
    logAnalyticsWorkspaceId: logAnalytics.outputs.id
    tags: commonTags
  }
}

module appServicePlan '../../modules/web/app-service-plan.bicep' = {
  name: 'stage02-app-service-plan'
  params: {
    name: appServicePlanName
    location: location
    skuName: skuName
    skuTier: appServicePlanSkuTier
    tags: commonTags
  }
}

module sqlServer '../../modules/data/sql-logical-server.bicep' = {
  name: 'stage02-sql-server'
  params: {
    name: sqlServerName
    location: location
    administratorLogin: sqlAdminLogin
    administratorLoginPassword: sqlAdminPassword
    allowAzureServices: true
    tags: commonTags
  }
}

module sqlDatabase '../../modules/data/sql-database.bicep' = {
  name: 'stage02-sql-database'
  params: {
    sqlServerName: sqlServer.outputs.name
    name: sqlDatabaseName
    location: location
    skuName: 'Basic'
    skuTier: 'Basic'
    tags: commonTags
  }
}

module keyVault '../../modules/foundation/key-vault.bicep' = {
  name: 'stage02-key-vault'
  params: {
    name: keyVaultName
    location: location
    tenantId: tenant().tenantId
    enableRbacAuthorization: true
    tags: commonTags
  }
}

module webApp '../../modules/web/web-app.bicep' = {
  name: 'stage02-web-app'
  params: {
    name: webAppName
    location: location
    appServicePlanId: appServicePlan.outputs.id
    appInsightsConnectionString: applicationInsights.outputs.connectionString
    appSettings: [
      {
        name: 'AZURE_REGION'
        value: location
      }
      {
        name: 'ConnectionStrings__DefaultConnection'
        value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=${sqlConnectionSecretName})'
      }
    ]
    tags: commonTags
  }
}

module webAppSlot '../../modules/web/web-app-slot.bicep' = {
  name: 'stage02-web-app-slot'
  params: {
    webAppName: webApp.outputs.name
    slotName: slotName
    location: location
    appServicePlanId: appServicePlan.outputs.id
    appSettings: [
      {
        name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
        value: applicationInsights.outputs.connectionString
      }
      {
        name: 'AZURE_REGION'
        value: location
      }
      {
        name: 'ConnectionStrings__DefaultConnection'
        value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=${sqlConnectionSecretName})'
      }
    ]
    tags: union(commonTags, {
      slot: slotName
    })
  }
}

module actionGroup '../../modules/foundation/action-group.bicep' = {
  name: 'stage02-action-group'
  params: {
    name: actionGroupName
    shortName: actionGroupShortName
    emailReceivers: [
      {
        name: 'primary-email'
        emailAddress: alertEmail
      }
    ]
    tags: commonTags
  }
}

module http5xxAlert '../../modules/foundation/metric-alerts.bicep' = {
  name: 'stage02-http5xx-alert'
  params: {
    name: metricAlertName
    alertDescription: 'Notify when the web app returns HTTP 5xx responses.'
    targetResourceId: webApp.outputs.id
    metricName: 'Http5xx'
    operator: 'GreaterThan'
    threshold: 0
    actionGroupId: actionGroup.outputs.id
    evaluationFrequency: 'PT5M'
    windowSize: 'PT5M'
    tags: commonTags
  }
}

resource keyVaultResource 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

resource sqlServerResource 'Microsoft.Sql/servers@2023-08-01-preview' existing = {
  name: sqlServerName
}

resource sqlEntraAdministrator 'Microsoft.Sql/servers/administrators@2023-08-01-preview' = {
  parent: sqlServerResource
  name: 'ActiveDirectory'
  properties: {
    administratorType: 'ActiveDirectory'
    login: empty(deployer().userPrincipalName) ? deployer().objectId : deployer().userPrincipalName
    sid: deployer().objectId
    tenantId: deployer().tenantId
  }
  dependsOn: [
    sqlServer
  ]
}

resource sqlConnectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVaultResource
  name: sqlConnectionSecretName
  properties: {
    value: sqlConnectionString
  }
  dependsOn: [
    sqlEntraAdministrator
    sqlDatabase
  ]
}

resource keyVaultSecretsUserRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(keyVaultResource.id, webAppName, subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6'))
  scope: keyVaultResource
  properties: {
    principalId: webApp.outputs.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6')
  }
}

output webAppName string = webApp.outputs.name
output webAppUrl string = 'https://${webApp.outputs.defaultHostName}'
output keyVaultName string = keyVault.outputs.name
output keyVaultUri string = keyVault.outputs.uri
output stagingSlotUrl string = 'https://${webAppSlot.outputs.defaultHostName}'
output sqlServerFqdn string = sqlServer.outputs.fullyQualifiedDomainName
