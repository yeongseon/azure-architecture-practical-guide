targetScope = 'resourceGroup'

@description('Base name used to derive all resource names. Lowercase letters and numbers only.')
@minLength(3)
@maxLength(12)
param appBaseName string

@description('Azure region for all Stage 1 resources.')
param location string = resourceGroup().location

@description('Administrator login for the Azure SQL logical server.')
param sqlAdministratorLogin string

@description('Administrator password for the Azure SQL logical server.')
@secure()
param sqlAdministratorLoginPassword string

@description('Resource tags applied to every resource in the stage.')
param tags object = {
  stage: 'stage-01-mvp'
  workload: 'practical-storefront'
}

var uniqueSuffix = uniqueString(resourceGroup().id)
var logAnalyticsName = 'log-${appBaseName}-${uniqueSuffix}'
var appInsightsName = 'appi-${appBaseName}-${uniqueSuffix}'
var appServicePlanName = 'plan-${appBaseName}-${uniqueSuffix}'
var webAppName = 'app-${appBaseName}-${uniqueSuffix}'
var sqlServerName = 'sql-${appBaseName}-${uniqueSuffix}'
var sqlDatabaseName = 'sqldb-storefront'

var sqlConnectionString = 'Server=tcp:${sqlServerName}${environment().suffixes.sqlServerHostname},1433;Initial Catalog=${sqlDatabaseName};Persist Security Info=False;User ID=${sqlAdministratorLogin};Password=${sqlAdministratorLoginPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'

module logAnalytics '../../modules/foundation/log-analytics-workspace.bicep' = {
  name: 'stage01-log-analytics'
  params: {
    name: logAnalyticsName
    location: location
    retentionInDays: 7
    tags: tags
  }
}

module appInsights '../../modules/foundation/application-insights.bicep' = {
  name: 'stage01-app-insights'
  params: {
    name: appInsightsName
    location: location
    workspaceResourceId: logAnalytics.outputs.id
    tags: tags
  }
}

module appServicePlan '../../modules/web/app-service-plan.bicep' = {
  name: 'stage01-app-service-plan'
  params: {
    name: appServicePlanName
    location: location
    skuName: 'B1'
    skuTier: 'Basic'
    linux: true
    tags: tags
  }
}

module sqlServer '../../modules/data/sql-logical-server.bicep' = {
  name: 'stage01-sql-server'
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
  name: 'stage01-sql-database'
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

module webApp '../../modules/web/web-app.bicep' = {
  name: 'stage01-web-app'
  params: {
    name: webAppName
    location: location
    appServicePlanId: appServicePlan.outputs.id
    linuxFxVersion: 'DOTNETCORE|8.0'
    appInsightsConnectionString: appInsights.outputs.connectionString
    additionalAppSettings: [
      {
        name: 'ConnectionStrings__StorefrontDb'
        value: sqlConnectionString
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
  ]
}

@description('Name of the deployed web app.')
output webAppName string = webApp.outputs.name

@description('Public HTTPS URL of the deployed web app.')
output webAppUrl string = 'https://${webApp.outputs.defaultHostName}'

@description('Name of the Application Insights component.')
output appInsightsName string = appInsights.outputs.name

@description('Fully qualified domain name of the SQL logical server.')
output sqlServerFqdn string = sqlServer.outputs.fullyQualifiedDomainName

@description('Name of the SQL database.')
output sqlDatabaseName string = sqlDatabase.outputs.name
