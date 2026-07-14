targetScope = 'resourceGroup'

@description('Base name used to derive all resource names. Lowercase letters and numbers only.')
@minLength(3)
@maxLength(12)
param appBaseName string

@description('Azure region for all Stage 2 resources.')
param location string = resourceGroup().location

@description('Administrator login for the Azure SQL logical server.')
param sqlAdministratorLogin string

@description('Administrator password for the Azure SQL logical server.')
@secure()
param sqlAdministratorLoginPassword string

@description('Entra ID principal display name to set as the SQL server Microsoft Entra administrator.')
param sqlEntraAdminLogin string

@description('Object ID of the Entra ID principal to set as the SQL server Microsoft Entra administrator.')
param sqlEntraAdminObjectId string

@description('Email address notified by the action group when an alert fires.')
param alertEmailAddress string

@description('Resource tags applied to every resource in the stage.')
param tags object = {
  stage: 'stage-02-production-baseline'
  workload: 'practical-storefront'
}

var uniqueSuffix = uniqueString(resourceGroup().id)
var logAnalyticsName = 'log-${appBaseName}-${uniqueSuffix}'
var appInsightsName = 'appi-${appBaseName}-${uniqueSuffix}'
var appServicePlanName = 'plan-${appBaseName}-${uniqueSuffix}'
var webAppName = 'app-${appBaseName}-${uniqueSuffix}'
var slotName = 'staging'
var keyVaultName = 'kv-${appBaseName}-${uniqueSuffix}'
var sqlServerName = 'sql-${appBaseName}-${uniqueSuffix}'
var sqlDatabaseName = 'sqldb-storefront'
var actionGroupName = 'ag-${appBaseName}-${uniqueSuffix}'
var sqlSecretName = 'SqlConnectionString'

var keyVaultSecretsUserRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6')

var sqlConnectionString = 'Server=tcp:${sqlServerName}${environment().suffixes.sqlServerHostname},1433;Initial Catalog=${sqlDatabaseName};Persist Security Info=False;User ID=${sqlAdministratorLogin};Password=${sqlAdministratorLoginPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'

module logAnalytics '../../modules/foundation/log-analytics-workspace.bicep' = {
  name: 'stage02-log-analytics'
  params: {
    name: logAnalyticsName
    location: location
    retentionInDays: 30
    tags: tags
  }
}

module appInsights '../../modules/foundation/application-insights.bicep' = {
  name: 'stage02-app-insights'
  params: {
    name: appInsightsName
    location: location
    workspaceResourceId: logAnalytics.outputs.id
    tags: tags
  }
}

module appServicePlan '../../modules/web/app-service-plan.bicep' = {
  name: 'stage02-app-service-plan'
  params: {
    name: appServicePlanName
    location: location
    skuName: 'S1'
    skuTier: 'Standard'
    linux: true
    tags: tags
  }
}

module sqlServer '../../modules/data/sql-logical-server.bicep' = {
  name: 'stage02-sql-server'
  params: {
    name: sqlServerName
    location: location
    administratorLogin: sqlAdministratorLogin
    administratorLoginPassword: sqlAdministratorLoginPassword
    publicNetworkAccess: 'Enabled'
    tags: tags
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
    maxSizeBytes: 2147483648
    tags: tags
  }
}

resource sqlServerExisting 'Microsoft.Sql/servers@2021-11-01' existing = {
  name: sqlServerName
}

resource allowAzureServices 'Microsoft.Sql/servers/firewallRules@2021-11-01' = {
  parent: sqlServerExisting
  name: 'AllowAllWindowsAzureIps'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
  dependsOn: [
    sqlServer
  ]
}

resource sqlEntraAdmin 'Microsoft.Sql/servers/administrators@2021-11-01' = {
  parent: sqlServerExisting
  name: 'ActiveDirectory'
  properties: {
    administratorType: 'ActiveDirectory'
    login: sqlEntraAdminLogin
    sid: sqlEntraAdminObjectId
    tenantId: subscription().tenantId
  }
  dependsOn: [
    sqlServer
  ]
}

module keyVault '../../modules/foundation/key-vault.bicep' = {
  name: 'stage02-key-vault'
  params: {
    name: keyVaultName
    location: location
    sku: 'standard'
    enableRbacAuthorization: true
    enablePurgeProtection: false
    publicNetworkAccess: 'Enabled'
    tags: tags
  }
}

resource keyVaultExisting 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

resource sqlConnectionSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVaultExisting
  name: sqlSecretName
  properties: {
    value: sqlConnectionString
  }
  dependsOn: [
    keyVault
  ]
}

var sqlSecretReference = '@Microsoft.KeyVault(SecretUri=${keyVault.outputs.vaultUri}secrets/${sqlSecretName})'

module webApp '../../modules/web/web-app.bicep' = {
  name: 'stage02-web-app'
  params: {
    name: webAppName
    location: location
    appServicePlanId: appServicePlan.outputs.id
    linuxFxVersion: 'DOTNETCORE|8.0'
    appInsightsConnectionString: appInsights.outputs.connectionString
    additionalAppSettings: [
      {
        name: 'ConnectionStrings__StorefrontDb'
        value: sqlSecretReference
      }
      {
        name: 'REGION'
        value: location
      }
      {
        name: 'ASPNETCORE_ENVIRONMENT'
        value: 'Production'
      }
    ]
    tags: tags
  }
  dependsOn: [
    sqlDatabase
    sqlConnectionSecret
  ]
}

module stagingSlot '../../modules/web/web-app-slot.bicep' = {
  name: 'stage02-staging-slot'
  params: {
    webAppName: webApp.outputs.name
    slotName: slotName
    location: location
    appServicePlanId: appServicePlan.outputs.id
    linuxFxVersion: 'DOTNETCORE|8.0'
    appSettings: [
      {
        name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
        value: appInsights.outputs.connectionString
      }
      {
        name: 'ConnectionStrings__StorefrontDb'
        value: sqlSecretReference
      }
      {
        name: 'REGION'
        value: location
      }
      {
        name: 'ASPNETCORE_ENVIRONMENT'
        value: 'Staging'
      }
    ]
    tags: tags
  }
}

module webAppKeyVaultRole '../../modules/foundation/role-assignment.bicep' = {
  name: 'stage02-webapp-kv-role'
  params: {
    principalId: webApp.outputs.principalId
    roleDefinitionId: keyVaultSecretsUserRoleId
    principalType: 'ServicePrincipal'
  }
}

module slotKeyVaultRole '../../modules/foundation/role-assignment.bicep' = {
  name: 'stage02-slot-kv-role'
  params: {
    principalId: stagingSlot.outputs.principalId
    roleDefinitionId: keyVaultSecretsUserRoleId
    principalType: 'ServicePrincipal'
  }
}

module actionGroup '../../modules/foundation/action-group.bicep' = {
  name: 'stage02-action-group'
  params: {
    name: actionGroupName
    groupShortName: 'storefront'
    emailReceivers: [
      {
        name: 'primary'
        emailAddress: alertEmailAddress
      }
    ]
    tags: tags
  }
}

module http5xxAlert '../../modules/foundation/metric-alerts.bicep' = {
  name: 'stage02-http5xx-alert'
  params: {
    name: 'alert-${appBaseName}-http5xx'
    alertDescription: 'Server-side 5xx responses exceeded the threshold on the web app.'
    targetResourceId: webApp.outputs.id
    metricNamespace: 'Microsoft.Web/sites'
    metricName: 'Http5xx'
    operator: 'GreaterThan'
    timeAggregation: 'Total'
    threshold: 10
    severity: 1
    actionGroupId: actionGroup.outputs.id
    tags: tags
  }
}

module responseTimeAlert '../../modules/foundation/metric-alerts.bicep' = {
  name: 'stage02-responsetime-alert'
  params: {
    name: 'alert-${appBaseName}-responsetime'
    alertDescription: 'Average HTTP response time exceeded the threshold on the web app.'
    targetResourceId: webApp.outputs.id
    metricNamespace: 'Microsoft.Web/sites'
    metricName: 'HttpResponseTime'
    operator: 'GreaterThan'
    timeAggregation: 'Average'
    threshold: 5
    severity: 2
    actionGroupId: actionGroup.outputs.id
    tags: tags
  }
}

@description('Name of the deployed web app.')
output webAppName string = webApp.outputs.name

@description('Public HTTPS URL of the deployed web app.')
output webAppUrl string = 'https://${webApp.outputs.defaultHostName}'

@description('Name of the staging deployment slot.')
output stagingSlotName string = stagingSlot.outputs.name

@description('Name of the Key Vault holding the SQL connection string.')
output keyVaultName string = keyVault.outputs.name

@description('Name of the Application Insights component.')
output appInsightsName string = appInsights.outputs.name

@description('Fully qualified domain name of the SQL logical server.')
output sqlServerFqdn string = sqlServer.outputs.fullyQualifiedDomainName

@description('Name of the SQL database.')
output sqlDatabaseName string = sqlDatabase.outputs.name

@description('Name of the action group notified by metric alerts.')
output actionGroupName string = actionGroup.outputs.name
