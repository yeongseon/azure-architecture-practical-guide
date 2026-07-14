targetScope = 'resourceGroup'

@description('Base name used to derive all resource names. Lowercase letters and numbers only.')
@minLength(3)
@maxLength(12)
param appBaseName string

@description('Primary Azure region. Hosts the active app stack and the read-write SQL server.')
param location string = resourceGroup().location

@description('Secondary Azure region. Hosts the passive app stack and the failover SQL server.')
param secondaryLocation string = 'japaneast'

@description('Administrator login for both Azure SQL logical servers.')
param sqlAdministratorLogin string

@description('Administrator password for both Azure SQL logical servers.')
@secure()
param sqlAdministratorLoginPassword string

@description('Entra ID principal display name to set as the SQL server Microsoft Entra administrator.')
param sqlEntraAdminLogin string

@description('Object ID of the Entra ID principal to set as the SQL server Microsoft Entra administrator.')
param sqlEntraAdminObjectId string

@description('Email address notified by the action group when an alert fires.')
param alertEmailAddress string

@description('Maximum number of primary web app instances the autoscale rule may scale out to.')
@minValue(2)
@maxValue(30)
param autoscaleMaximumCapacity int = 2

@description('Grace period in minutes before the failover group performs an automatic failover with potential data loss.')
param failoverGracePeriodMinutes int = 60

@description('Resource tags applied to every resource in the stage.')
param tags object = {
  stage: 'stage-05-resilience'
  workload: 'practical-storefront'
}

var uniqueSuffix = uniqueString(resourceGroup().id)
var logAnalyticsName = 'log-${appBaseName}-${uniqueSuffix}'
var appInsightsName = 'appi-${appBaseName}-${uniqueSuffix}'
var appServicePlanName = 'plan-${appBaseName}-${uniqueSuffix}'
var secondaryAppServicePlanName = 'plan-${appBaseName}-sec-${uniqueSuffix}'
var webAppName = 'app-${appBaseName}-${uniqueSuffix}'
var secondaryWebAppName = 'app-${appBaseName}-sec-${uniqueSuffix}'
var slotName = 'staging'
var keyVaultName = 'kv-${appBaseName}-${uniqueSuffix}'
var sqlServerName = 'sql-${appBaseName}-${uniqueSuffix}'
var sqlServerSecondaryName = 'sql-${appBaseName}-sec-${uniqueSuffix}'
var sqlDatabaseName = 'sqldb-storefront'
var failoverGroupName = 'fog-${appBaseName}-${uniqueSuffix}'
var actionGroupName = 'ag-${appBaseName}-${uniqueSuffix}'
var sqlSecretName = 'SqlConnectionString'
var autoscaleName = 'autoscale-${appBaseName}-${uniqueSuffix}'
var frontDoorName = 'afd-${appBaseName}-${uniqueSuffix}'
var frontDoorEndpointName = 'ep-${appBaseName}-${uniqueSuffix}'
var wafPolicyName = '${replace(appBaseName, '-', '')}${uniqueSuffix}waf'
var originGroupName = 'og-storefront'
var primaryOriginName = 'origin-primary'
var secondaryOriginName = 'origin-secondary'
var routeName = 'route-default'

var keyVaultSecretsUserRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6')

// The connection string targets the failover group LISTENER, not a specific server.
// The listener always points at whichever server currently holds the read-write role,
// so both regional app stacks use the identical connection string and survive a data-tier failover.
var failoverListenerFqdn = '${failoverGroupName}${environment().suffixes.sqlServerHostname}'
var sqlConnectionString = 'Server=tcp:${failoverListenerFqdn},1433;Initial Catalog=${sqlDatabaseName};Persist Security Info=False;User ID=${sqlAdministratorLogin};Password=${sqlAdministratorLoginPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'

module logAnalytics '../../modules/foundation/log-analytics-workspace.bicep' = {
  name: 'stage05-log-analytics'
  params: {
    name: logAnalyticsName
    location: location
    retentionInDays: 30
    tags: tags
  }
}

module appInsights '../../modules/foundation/application-insights.bicep' = {
  name: 'stage05-app-insights'
  params: {
    name: appInsightsName
    location: location
    workspaceResourceId: logAnalytics.outputs.id
    tags: tags
  }
}

// ---------------------------------------------------------------------------
// Compute — two regional stacks (primary active, secondary passive)
// ---------------------------------------------------------------------------

module appServicePlan '../../modules/web/app-service-plan.bicep' = {
  name: 'stage05-app-service-plan'
  params: {
    name: appServicePlanName
    location: location
    skuName: 'S1'
    skuTier: 'Standard'
    linux: true
    tags: tags
  }
}

module secondaryAppServicePlan '../../modules/web/app-service-plan.bicep' = {
  name: 'stage05-secondary-app-service-plan'
  params: {
    name: secondaryAppServicePlanName
    location: secondaryLocation
    skuName: 'S1'
    skuTier: 'Standard'
    linux: true
    tags: tags
  }
}

// ---------------------------------------------------------------------------
// Data — two SQL logical servers, one database, one failover group
// ---------------------------------------------------------------------------

module sqlServer '../../modules/data/sql-logical-server.bicep' = {
  name: 'stage05-sql-server-primary'
  params: {
    name: sqlServerName
    location: location
    administratorLogin: sqlAdministratorLogin
    administratorLoginPassword: sqlAdministratorLoginPassword
    publicNetworkAccess: 'Enabled'
    tags: tags
  }
}

module sqlServerSecondary '../../modules/data/sql-logical-server.bicep' = {
  name: 'stage05-sql-server-secondary'
  params: {
    name: sqlServerSecondaryName
    location: secondaryLocation
    administratorLogin: sqlAdministratorLogin
    administratorLoginPassword: sqlAdministratorLoginPassword
    publicNetworkAccess: 'Enabled'
    tags: tags
  }
}

// Only the PRIMARY database is created explicitly. The failover group seeds the
// matching secondary database on the partner server; creating it manually would collide.
module sqlDatabase '../../modules/data/sql-database.bicep' = {
  name: 'stage05-sql-database'
  params: {
    sqlServerName: sqlServer.outputs.name
    name: sqlDatabaseName
    location: location
    skuName: 'S0'
    skuTier: 'Standard'
    maxSizeBytes: 268435456000
    tags: tags
  }
}

module failoverGroup '../../modules/data/sql-failover-group.bicep' = {
  name: 'stage05-sql-failover-group'
  params: {
    primaryServerName: sqlServer.outputs.name
    name: failoverGroupName
    partnerServerId: sqlServerSecondary.outputs.id
    databaseIds: [
      sqlDatabase.outputs.id
    ]
    gracePeriodMinutes: failoverGracePeriodMinutes
  }
}

resource sqlServerExisting 'Microsoft.Sql/servers@2021-11-01' existing = {
  name: sqlServerName
}

resource sqlServerSecondaryExisting 'Microsoft.Sql/servers@2021-11-01' existing = {
  name: sqlServerSecondaryName
}

resource allowAzureServicesPrimary 'Microsoft.Sql/servers/firewallRules@2021-11-01' = {
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

resource allowAzureServicesSecondary 'Microsoft.Sql/servers/firewallRules@2021-11-01' = {
  parent: sqlServerSecondaryExisting
  name: 'AllowAllWindowsAzureIps'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
  dependsOn: [
    sqlServerSecondary
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

resource sqlEntraAdminSecondary 'Microsoft.Sql/servers/administrators@2021-11-01' = {
  parent: sqlServerSecondaryExisting
  name: 'ActiveDirectory'
  properties: {
    administratorType: 'ActiveDirectory'
    login: sqlEntraAdminLogin
    sid: sqlEntraAdminObjectId
    tenantId: subscription().tenantId
  }
  dependsOn: [
    sqlServerSecondary
  ]
}

// ---------------------------------------------------------------------------
// Secrets — one Key Vault, one connection string bound to the FOG listener
// ---------------------------------------------------------------------------

module keyVault '../../modules/foundation/key-vault.bicep' = {
  name: 'stage05-key-vault'
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

// ---------------------------------------------------------------------------
// Primary web app (active) + staging slot
// ---------------------------------------------------------------------------

module webApp '../../modules/web/web-app.bicep' = {
  name: 'stage05-web-app-primary'
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
        name: 'APP_REGION'
        value: 'primary'
      }
      {
        name: 'ASPNETCORE_ENVIRONMENT'
        value: 'Production'
      }
    ]
    tags: tags
  }
  dependsOn: [
    failoverGroup
    sqlConnectionSecret
  ]
}

module stagingSlot '../../modules/web/web-app-slot.bicep' = {
  name: 'stage05-staging-slot'
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
        name: 'APP_REGION'
        value: 'primary'
      }
      {
        name: 'ASPNETCORE_ENVIRONMENT'
        value: 'Staging'
      }
    ]
    tags: tags
  }
}

resource webAppExisting 'Microsoft.Web/sites@2023-12-01' existing = {
  name: webAppName
}

resource slotConfigNames 'Microsoft.Web/sites/config@2023-12-01' = {
  parent: webAppExisting
  name: 'slotConfigNames'
  properties: {
    appSettingNames: [
      'ASPNETCORE_ENVIRONMENT'
    ]
  }
  dependsOn: [
    webApp
    stagingSlot
  ]
}

// ---------------------------------------------------------------------------
// Secondary web app (passive failover target, no slot)
// ---------------------------------------------------------------------------

module secondaryWebApp '../../modules/web/web-app.bicep' = {
  name: 'stage05-web-app-secondary'
  params: {
    name: secondaryWebAppName
    location: secondaryLocation
    appServicePlanId: secondaryAppServicePlan.outputs.id
    linuxFxVersion: 'DOTNETCORE|8.0'
    appInsightsConnectionString: appInsights.outputs.connectionString
    additionalAppSettings: [
      {
        name: 'ConnectionStrings__StorefrontDb'
        value: sqlSecretReference
      }
      {
        name: 'REGION'
        value: secondaryLocation
      }
      {
        name: 'APP_REGION'
        value: 'secondary'
      }
      {
        name: 'ASPNETCORE_ENVIRONMENT'
        value: 'Production'
      }
    ]
    tags: tags
  }
  dependsOn: [
    failoverGroup
    sqlConnectionSecret
  ]
}

// ---------------------------------------------------------------------------
// Key Vault access — both regional app identities read the same secret
// ---------------------------------------------------------------------------

module webAppKeyVaultRole '../../modules/foundation/key-vault-role-assignment.bicep' = {
  name: 'stage05-webapp-kv-role'
  params: {
    keyVaultName: keyVaultName
    principalId: webApp.outputs.principalId
    roleDefinitionId: keyVaultSecretsUserRoleId
    principalType: 'ServicePrincipal'
  }
}

module slotKeyVaultRole '../../modules/foundation/key-vault-role-assignment.bicep' = {
  name: 'stage05-slot-kv-role'
  params: {
    keyVaultName: keyVaultName
    principalId: stagingSlot.outputs.principalId
    roleDefinitionId: keyVaultSecretsUserRoleId
    principalType: 'ServicePrincipal'
  }
}

module secondaryWebAppKeyVaultRole '../../modules/foundation/key-vault-role-assignment.bicep' = {
  name: 'stage05-secondary-webapp-kv-role'
  params: {
    keyVaultName: keyVaultName
    principalId: secondaryWebApp.outputs.principalId
    roleDefinitionId: keyVaultSecretsUserRoleId
    principalType: 'ServicePrincipal'
  }
}

// ---------------------------------------------------------------------------
// Autoscale + alerts (primary region only; secondary is a passive target)
// ---------------------------------------------------------------------------

module autoscale '../../modules/foundation/autoscale-settings.bicep' = {
  name: 'stage05-autoscale'
  params: {
    name: autoscaleName
    location: location
    targetResourceId: appServicePlan.outputs.id
    minimumCapacity: 1
    maximumCapacity: autoscaleMaximumCapacity
    defaultCapacity: 1
    metricName: 'CpuPercentage'
    metricNamespace: 'Microsoft.Web/serverfarms'
    scaleOutThreshold: 70
    scaleInThreshold: 30
    tags: tags
  }
}

module actionGroup '../../modules/foundation/action-group.bicep' = {
  name: 'stage05-action-group'
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
  name: 'stage05-http5xx-alert'
  params: {
    name: 'alert-${appBaseName}-http5xx'
    alertDescription: 'Server-side 5xx responses exceeded the threshold on the primary web app.'
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
  name: 'stage05-responsetime-alert'
  params: {
    name: 'alert-${appBaseName}-responsetime'
    alertDescription: 'Average HTTP response time exceeded the threshold on the primary web app.'
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

// ---------------------------------------------------------------------------
// Front Door — one origin group, two origins with priority-based failover
// ---------------------------------------------------------------------------

module frontDoor '../../modules/web/front-door-standard.bicep' = {
  name: 'stage05-front-door'
  params: {
    name: frontDoorName
    endpointName: frontDoorEndpointName
    skuName: 'Standard_AzureFrontDoor'
    wafPolicyName: wafPolicyName
    wafMode: 'Prevention'
    tags: tags
  }
}

resource frontDoorProfileExisting 'Microsoft.Cdn/profiles@2023-05-01' existing = {
  name: frontDoorName
}

resource frontDoorEndpointExisting 'Microsoft.Cdn/profiles/afdEndpoints@2023-05-01' existing = {
  parent: frontDoorProfileExisting
  name: frontDoorEndpointName
}

resource originGroup 'Microsoft.Cdn/profiles/originGroups@2023-05-01' = {
  parent: frontDoorProfileExisting
  name: originGroupName
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
      additionalLatencyInMilliseconds: 50
    }
    healthProbeSettings: {
      probePath: '/healthz'
      probeRequestType: 'GET'
      probeProtocol: 'Https'
      probeIntervalInSeconds: 100
    }
  }
  dependsOn: [
    frontDoor
  ]
}

// Priority 1 origin is preferred. Front Door only routes to the priority 2 origin
// when every higher-priority origin fails its health probe (regional app-tier failover).
resource primaryOrigin 'Microsoft.Cdn/profiles/originGroups/origins@2023-05-01' = {
  parent: originGroup
  name: primaryOriginName
  properties: {
    hostName: webApp.outputs.defaultHostName
    httpPort: 80
    httpsPort: 443
    originHostHeader: webApp.outputs.defaultHostName
    priority: 1
    weight: 1000
    enabledState: 'Enabled'
    enforceCertificateNameCheck: true
  }
}

resource secondaryOrigin 'Microsoft.Cdn/profiles/originGroups/origins@2023-05-01' = {
  parent: originGroup
  name: secondaryOriginName
  properties: {
    hostName: secondaryWebApp.outputs.defaultHostName
    httpPort: 80
    httpsPort: 443
    originHostHeader: secondaryWebApp.outputs.defaultHostName
    priority: 2
    weight: 1000
    enabledState: 'Enabled'
    enforceCertificateNameCheck: true
  }
  dependsOn: [
    primaryOrigin
  ]
}

resource route 'Microsoft.Cdn/profiles/afdEndpoints/routes@2023-05-01' = {
  parent: frontDoorEndpointExisting
  name: routeName
  properties: {
    originGroup: {
      id: originGroup.id
    }
    supportedProtocols: [
      'Http'
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    forwardingProtocol: 'HttpsOnly'
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Enabled'
    enabledState: 'Enabled'
  }
  dependsOn: [
    primaryOrigin
    secondaryOrigin
  ]
}

@description('Name of the primary (active) web app.')
output webAppName string = webApp.outputs.name

@description('Public HTTPS URL of the primary origin web app (direct, bypassing Front Door).')
output webAppUrl string = 'https://${webApp.outputs.defaultHostName}'

@description('Name of the secondary (passive) web app.')
output secondaryWebAppName string = secondaryWebApp.outputs.name

@description('Public HTTPS URL of the secondary origin web app (direct, bypassing Front Door).')
output secondaryWebAppUrl string = 'https://${secondaryWebApp.outputs.defaultHostName}'

@description('Public HTTPS URL of the Front Door endpoint (the front door for user traffic).')
output frontDoorEndpointUrl string = 'https://${frontDoor.outputs.endpointHostName}'

@description('Name of the Front Door profile.')
output frontDoorProfileName string = frontDoorName

@description('Name of the Front Door endpoint.')
output frontDoorEndpointName string = frontDoorEndpointName

@description('Name of the Front Door origin group holding both regional origins.')
output originGroupName string = originGroupName

@description('Name of the autoscale setting on the primary plan.')
output autoscaleName string = autoscale.outputs.name

@description('Name of the primary staging deployment slot.')
output stagingSlotName string = stagingSlot.outputs.name

@description('Name of the Key Vault holding the SQL connection string.')
output keyVaultName string = keyVault.outputs.name

@description('Name of the Application Insights component.')
output appInsightsName string = appInsights.outputs.name

@description('Fully qualified domain name of the primary SQL logical server.')
output sqlServerFqdn string = sqlServer.outputs.fullyQualifiedDomainName

@description('Name of the primary SQL logical server (read-write role at deploy time).')
output sqlServerName string = sqlServer.outputs.name

@description('Name of the secondary SQL logical server (failover partner).')
output sqlServerSecondaryName string = sqlServerSecondary.outputs.name

@description('Name of the SQL failover group. Also the DNS label of the read-write listener.')
output failoverGroupName string = failoverGroupName

@description('Fully qualified domain name of the failover group read-write listener.')
output failoverListenerFqdn string = failoverListenerFqdn

@description('Name of the SQL database.')
output sqlDatabaseName string = sqlDatabase.outputs.name

@description('Name of the action group notified by metric alerts.')
output actionGroupName string = actionGroup.outputs.name

@description('Secondary Azure region hosting the passive stack.')
output secondaryLocation string = secondaryLocation
