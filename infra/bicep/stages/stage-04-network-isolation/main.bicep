targetScope = 'resourceGroup'

@description('Base name used to derive all resource names. Lowercase letters and numbers only.')
@minLength(3)
@maxLength(12)
param appBaseName string

@description('Azure region for all Stage 4 resources.')
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

@description('Maximum number of web app instances the autoscale rule may scale out to.')
@minValue(2)
@maxValue(30)
param autoscaleMaximumCapacity int = 2

@description('Address space for the stage virtual network.')
param vnetAddressPrefix string = '10.10.0.0/16'

@description('Address prefix for the App Service regional VNet integration subnet.')
param integrationSubnetPrefix string = '10.10.1.0/24'

@description('Address prefix for the private endpoint subnet.')
param privateEndpointSubnetPrefix string = '10.10.2.0/24'

@description('Resource tags applied to every resource in the stage.')
param tags object = {
  stage: 'stage-04-network-isolation'
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
var autoscaleName = 'autoscale-${appBaseName}-${uniqueSuffix}'
var frontDoorName = 'afd-${appBaseName}-${uniqueSuffix}'
var frontDoorEndpointName = 'ep-${appBaseName}-${uniqueSuffix}'
var wafPolicyName = '${replace(appBaseName, '-', '')}${uniqueSuffix}waf'
var originGroupName = 'og-storefront'
var originName = 'origin-webapp'
var routeName = 'route-default'
var vnetName = 'vnet-${appBaseName}-${uniqueSuffix}'
var integrationSubnetName = 'snet-appservice'
var privateEndpointSubnetName = 'snet-privateendpoints'
var sqlPrivateEndpointName = 'pe-sql-${appBaseName}-${uniqueSuffix}'
var sqlPrivateDnsZoneName = 'privatelink${environment().suffixes.sqlServerHostname}'

var keyVaultSecretsUserRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6')

var sqlConnectionString = 'Server=tcp:${sqlServerName}${environment().suffixes.sqlServerHostname},1433;Initial Catalog=${sqlDatabaseName};Persist Security Info=False;User ID=${sqlAdministratorLogin};Password=${sqlAdministratorLoginPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'

module network '../../modules/network/virtual-network.bicep' = {
  name: 'stage04-vnet'
  params: {
    name: vnetName
    location: location
    addressPrefixes: [
      vnetAddressPrefix
    ]
    subnets: [
      {
        name: integrationSubnetName
        addressPrefix: integrationSubnetPrefix
        delegation: 'Microsoft.Web/serverFarms'
      }
      {
        name: privateEndpointSubnetName
        addressPrefix: privateEndpointSubnetPrefix
        privateEndpointNetworkPolicies: 'Disabled'
      }
    ]
    tags: tags
  }
}

module sqlPrivateDnsZone '../../modules/network/private-dns-zone.bicep' = {
  name: 'stage04-sql-private-dns'
  params: {
    name: sqlPrivateDnsZoneName
    virtualNetworkLinks: [
      {
        name: 'link-to-${vnetName}'
        virtualNetworkId: network.outputs.id
      }
    ]
    tags: tags
  }
}

module logAnalytics '../../modules/foundation/log-analytics-workspace.bicep' = {
  name: 'stage04-log-analytics'
  params: {
    name: logAnalyticsName
    location: location
    retentionInDays: 30
    tags: tags
  }
}

module appInsights '../../modules/foundation/application-insights.bicep' = {
  name: 'stage04-app-insights'
  params: {
    name: appInsightsName
    location: location
    workspaceResourceId: logAnalytics.outputs.id
    tags: tags
  }
}

module appServicePlan '../../modules/web/app-service-plan.bicep' = {
  name: 'stage04-app-service-plan'
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
  name: 'stage04-sql-server'
  params: {
    name: sqlServerName
    location: location
    administratorLogin: sqlAdministratorLogin
    administratorLoginPassword: sqlAdministratorLoginPassword
    publicNetworkAccess: 'Disabled'
    tags: tags
  }
}

module sqlDatabase '../../modules/data/sql-database.bicep' = {
  name: 'stage04-sql-database'
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

module sqlPrivateEndpoint '../../modules/network/private-endpoint-sql.bicep' = {
  name: 'stage04-sql-private-endpoint'
  params: {
    name: sqlPrivateEndpointName
    location: location
    subnetId: network.outputs.subnetIds[1]
    sqlServerId: sqlServer.outputs.id
    privateDnsZoneId: sqlPrivateDnsZone.outputs.id
    tags: tags
  }
}

module keyVault '../../modules/foundation/key-vault.bicep' = {
  name: 'stage04-key-vault'
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
  name: 'stage04-web-app'
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
      {
        name: 'WEBSITE_VNET_ROUTE_ALL'
        value: '1'
      }
    ]
    tags: tags
  }
  dependsOn: [
    sqlDatabase
    sqlConnectionSecret
  ]
}

resource webAppExisting 'Microsoft.Web/sites@2023-12-01' existing = {
  name: webAppName
}

resource webAppVnetIntegration 'Microsoft.Web/sites/networkConfig@2023-12-01' = {
  parent: webAppExisting
  name: 'virtualNetwork'
  properties: {
    subnetResourceId: network.outputs.subnetIds[0]
    swiftSupported: true
  }
  dependsOn: [
    webApp
  ]
}

module stagingSlot '../../modules/web/web-app-slot.bicep' = {
  name: 'stage04-staging-slot'
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
      {
        name: 'WEBSITE_VNET_ROUTE_ALL'
        value: '1'
      }
    ]
    tags: tags
  }
}

resource stagingSlotExisting 'Microsoft.Web/sites/slots@2023-12-01' existing = {
  parent: webAppExisting
  name: slotName
}

resource slotVnetIntegration 'Microsoft.Web/sites/slots/networkConfig@2023-12-01' = {
  parent: stagingSlotExisting
  name: 'virtualNetwork'
  properties: {
    subnetResourceId: network.outputs.subnetIds[0]
    swiftSupported: true
  }
  dependsOn: [
    stagingSlot
  ]
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
    webAppVnetIntegration
  ]
}

module webAppKeyVaultRole '../../modules/foundation/key-vault-role-assignment.bicep' = {
  name: 'stage04-webapp-kv-role'
  params: {
    keyVaultName: keyVaultName
    principalId: webApp.outputs.principalId
    roleDefinitionId: keyVaultSecretsUserRoleId
    principalType: 'ServicePrincipal'
  }
}

module slotKeyVaultRole '../../modules/foundation/key-vault-role-assignment.bicep' = {
  name: 'stage04-slot-kv-role'
  params: {
    keyVaultName: keyVaultName
    principalId: stagingSlot.outputs.principalId
    roleDefinitionId: keyVaultSecretsUserRoleId
    principalType: 'ServicePrincipal'
  }
}

module autoscale '../../modules/foundation/autoscale-settings.bicep' = {
  name: 'stage04-autoscale'
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
  name: 'stage04-action-group'
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
  name: 'stage04-http5xx-alert'
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
  name: 'stage04-responsetime-alert'
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

module frontDoor '../../modules/web/front-door-standard.bicep' = {
  name: 'stage04-front-door'
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

resource origin 'Microsoft.Cdn/profiles/originGroups/origins@2023-05-01' = {
  parent: originGroup
  name: originName
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
    origin
  ]
}

@description('Name of the deployed web app.')
output webAppName string = webApp.outputs.name

@description('Public HTTPS URL of the origin web app (direct, bypassing Front Door).')
output webAppUrl string = 'https://${webApp.outputs.defaultHostName}'

@description('Public HTTPS URL of the Front Door endpoint (the front door for user traffic).')
output frontDoorEndpointUrl string = 'https://${frontDoor.outputs.endpointHostName}'

@description('Name of the Front Door profile.')
output frontDoorProfileName string = frontDoorName

@description('Name of the Front Door endpoint.')
output frontDoorEndpointName string = frontDoorEndpointName

@description('Name of the Front Door origin group.')
output originGroupName string = originGroupName

@description('Name of the autoscale setting.')
output autoscaleName string = autoscale.outputs.name

@description('Name of the staging deployment slot.')
output stagingSlotName string = stagingSlot.outputs.name

@description('Name of the Key Vault holding the SQL connection string.')
output keyVaultName string = keyVault.outputs.name

@description('Name of the Application Insights component.')
output appInsightsName string = appInsights.outputs.name

@description('Fully qualified domain name of the SQL logical server.')
output sqlServerFqdn string = sqlServer.outputs.fullyQualifiedDomainName

@description('Name of the SQL logical server.')
output sqlServerName string = sqlServer.outputs.name

@description('Name of the SQL database.')
output sqlDatabaseName string = sqlDatabase.outputs.name

@description('Name of the action group notified by metric alerts.')
output actionGroupName string = actionGroup.outputs.name

@description('Name of the stage virtual network.')
output vnetName string = network.outputs.name

@description('Name of the SQL private endpoint.')
output sqlPrivateEndpointName string = sqlPrivateEndpoint.outputs.name

@description('Name of the private DNS zone for SQL.')
output sqlPrivateDnsZoneName string = sqlPrivateDnsZone.outputs.name
