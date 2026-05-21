targetScope = 'resourceGroup'

@description('Primary Azure region for the Stage 5 resilience deployment.')
param location string

@description('Secondary Azure region used for regional failover.')
param secondaryLocation string = 'japaneast'

@description('Application name prefix used to derive resource names.')
param appName string

@description('Administrator login name for the Azure SQL logical servers.')
param sqlAdminLogin string

@description('Administrator login password for the Azure SQL logical servers.')
@secure()
param sqlAdminPassword string

@description('Email address used by the Azure Monitor action group.')
param alertEmail string

var uniqueSuffix = take(toLower(uniqueString(subscription().subscriptionId, resourceGroup().id, appName)), 8)
var appNameCompact = toLower(replace(appName, '-', ''))
var logAnalyticsWorkspaceName = take('${appNameCompact}law${uniqueSuffix}', 63)
var applicationInsightsName = take('${appNameCompact}appi${uniqueSuffix}', 260)
var primaryAppServicePlanName = take('${appNameCompact}asppri${uniqueSuffix}', 40)
var secondaryAppServicePlanName = take('${appNameCompact}aspsec${uniqueSuffix}', 40)
var primaryWebAppResourceName = take('${appNameCompact}webpri${uniqueSuffix}', 60)
var secondaryWebAppResourceName = take('${appNameCompact}websec${uniqueSuffix}', 60)
var slotName = 'staging'
var primarySqlServerName = take('${appNameCompact}sqlpri${uniqueSuffix}', 63)
var secondarySqlServerName = take('${appNameCompact}sqlsec${uniqueSuffix}', 63)
var sqlDatabaseName = take('${appNameCompact}db${uniqueSuffix}', 128)
var keyVaultName = take('${appNameCompact}kv${uniqueSuffix}', 24)
var actionGroupName = '${appName}-ag'
var actionGroupShortName = take('s5${appNameCompact}', 12)
var metricAlertName = '${appName}-http5xx-alert'
var autoscaleSettingName = '${appName}-autoscale'
var virtualNetworkName = take('${appNameCompact}vnet${uniqueSuffix}', 64)
var sqlServerDnsSuffix = environment().suffixes.sqlServerHostname
var privateDnsZoneName = 'privatelink.${sqlServerDnsSuffix}'
var privateEndpointName = take('${appNameCompact}sqlpe${uniqueSuffix}', 80)
var sqlFailoverGroupResourceName = take('${appNameCompact}fog${uniqueSuffix}', 63)
var frontDoorProfileName = take('${appNameCompact}afd${uniqueSuffix}', 90)
var frontDoorEndpointName = take('${appNameCompact}fd${uniqueSuffix}', 50)
var frontDoorOriginGroupName = 'active-passive-origins'
var frontDoorRouteName = 'default-route'
var frontDoorWafPolicyName = take('${appNameCompact}waf${uniqueSuffix}', 128)
var frontDoorSecurityPolicyName = '${frontDoorEndpointName}-waf-policy'
var sqlConnectionSecretName = 'SqlConnectionString'
var secondarySqlConnectionSecretName = 'SecondarySqlConnectionString'
var failoverGroupReadWriteListener = '${sqlFailoverGroupResourceName}.${sqlServerDnsSuffix}'
var keyVaultSecretsUserRoleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6')
var commonTags = {
  architecture: 'practical-journey'
  stage: 'stage-05-resilience'
  workload: appName
}
var primaryTags = union(commonTags, {
  regionRole: 'primary'
  azureRegion: location
})
var secondaryTags = union(commonTags, {
  regionRole: 'secondary'
  azureRegion: secondaryLocation
})
var globalTags = union(commonTags, {
  scope: 'global'
})
var sqlConnectionString = 'Server=tcp:${failoverGroupReadWriteListener},1433;Initial Catalog=${sqlDatabaseName};Persist Security Info=False;User ID=${sqlAdminLogin};Password=${sqlAdminPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'
var secondarySqlConnectionString = 'Server=tcp:${secondarySqlServerName}.${sqlServerDnsSuffix},1433;Initial Catalog=${sqlDatabaseName};Persist Security Info=False;User ID=${sqlAdminLogin};Password=${sqlAdminPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'

module logAnalytics '../../modules/foundation/log-analytics-workspace.bicep' = {
  name: 'stage05-log-analytics'
  params: {
    name: logAnalyticsWorkspaceName
    location: location
    retentionInDays: 7
    tags: primaryTags
  }
}

module applicationInsights '../../modules/foundation/application-insights.bicep' = {
  name: 'stage05-application-insights'
  params: {
    name: applicationInsightsName
    location: location
    logAnalyticsWorkspaceId: logAnalytics.outputs.id
    tags: primaryTags
  }
}

module primaryAppServicePlan '../../modules/web/app-service-plan.bicep' = {
  name: 'stage05-primary-app-service-plan'
  params: {
    name: primaryAppServicePlanName
    location: location
    skuName: 'S1'
    skuTier: 'Standard'
    tags: primaryTags
  }
}

module primarySqlServer '../../modules/data/sql-logical-server.bicep' = {
  name: 'stage05-primary-sql-server'
  params: {
    name: primarySqlServerName
    location: location
    administratorLogin: sqlAdminLogin
    administratorLoginPassword: sqlAdminPassword
    enableAadAdminOnly: false
    aadAdminLogin: empty(deployer().userPrincipalName) ? deployer().objectId : deployer().userPrincipalName
    aadAdminSid: deployer().objectId
    aadAdminTenantId: deployer().tenantId
    publicNetworkAccess: 'Disabled'
    tags: primaryTags
  }
}

module primarySqlDatabase '../../modules/data/sql-database.bicep' = {
  name: 'stage05-primary-sql-database'
  params: {
    sqlServerName: primarySqlServer.outputs.name
    name: sqlDatabaseName
    location: location
    skuName: 'S0'
    skuTier: 'Standard'
    maxSizeBytes: 268435456000
    tags: primaryTags
  }
}

module keyVault '../../modules/foundation/key-vault.bicep' = {
  name: 'stage05-key-vault'
  params: {
    name: keyVaultName
    location: location
    tenantId: tenant().tenantId
    enableRbacAuthorization: true
    tags: primaryTags
  }
}

module primaryWebApp '../../modules/web/web-app.bicep' = {
  name: 'stage05-primary-web-app'
  params: {
    name: primaryWebAppResourceName
    location: location
    appServicePlanId: primaryAppServicePlan.outputs.id
    appInsightsConnectionString: applicationInsights.outputs.connectionString
    virtualNetworkSubnetId: virtualNetwork.outputs.subnetIds['app-integration']
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
    tags: primaryTags
  }
}

module webAppSlot '../../modules/web/web-app-slot.bicep' = {
  name: 'stage05-web-app-slot'
  params: {
    webAppName: primaryWebApp.outputs.name
    slotName: slotName
    location: location
    appServicePlanId: primaryAppServicePlan.outputs.id
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
    tags: union(primaryTags, {
      slot: slotName
    })
  }
}

module actionGroup '../../modules/foundation/action-group.bicep' = {
  name: 'stage05-action-group'
  params: {
    name: actionGroupName
    shortName: actionGroupShortName
    emailReceivers: [
      {
        name: 'primary-email'
        emailAddress: alertEmail
      }
    ]
    tags: primaryTags
  }
}

module http5xxAlert '../../modules/foundation/metric-alerts.bicep' = {
  name: 'stage05-http5xx-alert'
  params: {
    name: metricAlertName
    alertDescription: 'Notify when the primary web app returns HTTP 5xx responses.'
    targetResourceId: primaryWebApp.outputs.id
    metricName: 'Http5xx'
    operator: 'GreaterThan'
    threshold: 0
    actionGroupId: actionGroup.outputs.id
    evaluationFrequency: 'PT5M'
    windowSize: 'PT5M'
    tags: primaryTags
  }
}

module autoscale '../../modules/foundation/autoscale-settings.bicep' = {
  name: 'stage05-autoscale'
  params: {
    name: autoscaleSettingName
    location: location
    targetResourceId: primaryAppServicePlan.outputs.id
    metricResourceId: primaryAppServicePlan.outputs.id
    minCapacity: '1'
    maxCapacity: '2'
    defaultCapacity: '1'
    tags: primaryTags
  }
}

module virtualNetwork '../../modules/network/virtual-network.bicep' = {
  name: 'stage05-virtual-network'
  params: {
    name: virtualNetworkName
    location: location
    addressPrefix: '10.50.0.0/16'
    subnets: [
      {
        name: 'app-integration'
        addressPrefix: '10.50.0.0/24'
        delegations: [
          {
            name: 'app-service-delegation'
            serviceName: 'Microsoft.Web/serverFarms'
          }
        ]
      }
      {
        name: 'private-endpoints'
        addressPrefix: '10.50.1.0/24'
      }
    ]
    tags: primaryTags
  }
}

module privateDnsZone '../../modules/network/private-dns-zone.bicep' = {
  name: 'stage05-private-dns-zone'
  params: {
    name: privateDnsZoneName
    virtualNetworkId: virtualNetwork.outputs.id
    registrationEnabled: false
    tags: primaryTags
  }
}

module privateEndpointSql '../../modules/network/private-endpoint-sql.bicep' = {
  name: 'stage05-private-endpoint-sql'
  params: {
    name: privateEndpointName
    location: location
    subnetId: virtualNetwork.outputs.subnetIds['private-endpoints']
    sqlServerId: primarySqlServer.outputs.id
    privateDnsZoneId: privateDnsZone.outputs.id
    tags: primaryTags
  }
}

module secondaryAppServicePlan '../../modules/web/app-service-plan.bicep' = {
  name: 'stage05-secondary-app-service-plan'
  params: {
    name: secondaryAppServicePlanName
    location: secondaryLocation
    skuName: 'S1'
    skuTier: 'Standard'
    tags: secondaryTags
  }
}

module secondaryWebApp '../../modules/web/web-app.bicep' = {
  name: 'stage05-secondary-web-app'
  params: {
    name: secondaryWebAppResourceName
    location: secondaryLocation
    appServicePlanId: secondaryAppServicePlan.outputs.id
    appInsightsConnectionString: applicationInsights.outputs.connectionString
    appSettings: [
      {
        name: 'AZURE_REGION'
        value: secondaryLocation
      }
      {
        name: 'ConnectionStrings__DefaultConnection'
        value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=${secondarySqlConnectionSecretName})'
      }
    ]
    tags: secondaryTags
  }
}

module secondarySqlServer '../../modules/data/sql-logical-server.bicep' = {
  name: 'stage05-secondary-sql-server'
  params: {
    name: secondarySqlServerName
    location: secondaryLocation
    administratorLogin: sqlAdminLogin
    administratorLoginPassword: sqlAdminPassword
    enableAadAdminOnly: false
    aadAdminLogin: empty(deployer().userPrincipalName) ? deployer().objectId : deployer().userPrincipalName
    aadAdminSid: deployer().objectId
    aadAdminTenantId: deployer().tenantId
    publicNetworkAccess: 'Enabled'
    allowAzureServices: true
    tags: secondaryTags
  }
}

module sqlFailoverGroup '../../modules/data/sql-failover-group.bicep' = {
  name: 'stage05-sql-failover-group'
  params: {
    name: sqlFailoverGroupResourceName
    sqlServerName: primarySqlServer.outputs.name
    partnerServerId: secondarySqlServer.outputs.id
    databaseIds: [
      primarySqlDatabase.outputs.id
    ]
    readWriteFailoverPolicyMode: 'Automatic'
    failoverGracePeriodMinutes: 60
  }
}

resource keyVaultResource 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

resource sqlConnectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVaultResource
  name: sqlConnectionSecretName
  properties: {
    value: sqlConnectionString
  }
  dependsOn: [
    sqlFailoverGroup
  ]
}

resource secondarySqlConnectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVaultResource
  name: secondarySqlConnectionSecretName
  properties: {
    value: secondarySqlConnectionString
  }
  dependsOn: [
    sqlFailoverGroup
  ]
}

resource primaryKeyVaultSecretsUserRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(keyVaultResource.id, primaryWebAppResourceName, keyVaultSecretsUserRoleDefinitionId)
  scope: keyVaultResource
  properties: {
    principalId: primaryWebApp.outputs.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: keyVaultSecretsUserRoleDefinitionId
  }
}

resource secondaryKeyVaultSecretsUserRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(keyVaultResource.id, secondaryWebAppResourceName, keyVaultSecretsUserRoleDefinitionId)
  scope: keyVaultResource
  properties: {
    principalId: secondaryWebApp.outputs.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: keyVaultSecretsUserRoleDefinitionId
  }
}

resource frontDoorProfile 'Microsoft.Cdn/profiles@2024-02-01' = {
  name: frontDoorProfileName
  location: 'global'
  tags: globalTags
  sku: {
    name: 'Standard_AzureFrontDoor'
  }
}

resource afdEndpoint 'Microsoft.Cdn/profiles/afdEndpoints@2024-02-01' = {
  parent: frontDoorProfile
  name: frontDoorEndpointName
  location: 'global'
  properties: {
    enabledState: 'Enabled'
  }
}

resource frontDoorOriginGroup 'Microsoft.Cdn/profiles/originGroups@2024-02-01' = {
  parent: frontDoorProfile
  name: frontDoorOriginGroupName
  properties: {
    healthProbeSettings: {
      probePath: '/healthz'
      probeRequestType: 'GET'
      probeProtocol: 'Https'
      probeIntervalInSeconds: 120
    }
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
      additionalLatencyInMilliseconds: 50
    }
    sessionAffinityState: 'Disabled'
  }
}

resource primaryOrigin 'Microsoft.Cdn/profiles/originGroups/origins@2024-02-01' = {
  parent: frontDoorOriginGroup
  name: 'primary-origin'
  properties: {
    hostName: primaryWebApp.outputs.defaultHostName
    httpPort: 80
    httpsPort: 443
    originHostHeader: primaryWebApp.outputs.defaultHostName
    priority: 1
    weight: 1000
    enabledState: 'Enabled'
    enforceCertificateNameCheck: true
  }
}

resource secondaryOrigin 'Microsoft.Cdn/profiles/originGroups/origins@2024-02-01' = {
  parent: frontDoorOriginGroup
  name: 'secondary-origin'
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
}

resource frontDoorRoute 'Microsoft.Cdn/profiles/afdEndpoints/routes@2024-02-01' = {
  parent: afdEndpoint
  name: frontDoorRouteName
  properties: {
    originGroup: {
      id: frontDoorOriginGroup.id
    }
    supportedProtocols: [
      'Http'
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    forwardingProtocol: 'HttpsOnly'
    httpsRedirect: 'Enabled'
    linkToDefaultDomain: 'Enabled'
    enabledState: 'Enabled'
    originPath: ''
  }
}

resource frontDoorWafPolicy 'Microsoft.Network/FrontDoorWebApplicationFirewallPolicies@2024-02-01' = {
  name: frontDoorWafPolicyName
  location: 'global'
  tags: globalTags
  properties: {
    policySettings: {
      enabledState: 'Enabled'
      mode: 'Prevention'
      customBlockResponseStatusCode: 403
      customBlockResponseBody: null
      requestBodyCheck: 'Enabled'
    }
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: 'DefaultRuleSet'
          ruleSetVersion: '1.0'
        }
      ]
    }
  }
}

resource frontDoorSecurityPolicy 'Microsoft.Cdn/profiles/securityPolicies@2024-02-01' = {
  parent: frontDoorProfile
  name: frontDoorSecurityPolicyName
  properties: {
    parameters: {
      type: 'WebApplicationFirewall'
      wafPolicy: {
        id: frontDoorWafPolicy.id
      }
      associations: [
        {
          domains: [
            {
              id: afdEndpoint.id
            }
          ]
          patternsToMatch: [
            '/*'
          ]
        }
      ]
    }
  }
}

@description('Azure Front Door default endpoint for the multi-region application.')
output frontDoorEndpoint string = 'https://${afdEndpoint.properties.hostName}'

@description('Name of the primary region web app.')
output primaryWebAppName string = primaryWebApp.outputs.name

@description('Name of the secondary region web app.')
output secondaryWebAppName string = secondaryWebApp.outputs.name

@description('Name of the Azure SQL failover group.')
output failoverGroupName string = sqlFailoverGroupResourceName

@description('Read-write listener endpoint for the Azure SQL failover group.')
output failoverGroupReadWriteEndpoint string = failoverGroupReadWriteListener
