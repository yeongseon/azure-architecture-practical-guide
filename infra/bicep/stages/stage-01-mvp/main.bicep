targetScope = 'resourceGroup'

@description('Azure region for the Stage 1 MVP deployment.')
param location string = resourceGroup().location

@description('Base application name used to derive Stage 1 resource names.')
param appName string

@description('Administrator login name for the Azure SQL logical server.')
param sqlAdminLogin string

@description('Administrator login password for the Azure SQL logical server.')
@secure()
param sqlAdminPassword string

var logAnalyticsWorkspaceName = 'law-${appName}'
var applicationInsightsName = 'ai-${appName}'
var appServicePlanName = 'plan-${appName}'
var webAppName = 'app-${appName}'
var sqlServerName = 'sql-${appName}'
var sqlDatabaseName = 'sqldb-${appName}'
var commonTags = {
  architectureStage: 'stage-01-mvp'
  workload: appName
}

module logAnalyticsWorkspace '../../modules/foundation/log-analytics-workspace.bicep' = {
  name: 'stage01-logAnalyticsWorkspace'
  params: {
    location: location
    name: logAnalyticsWorkspaceName
    retentionInDays: 7
    tags: commonTags
  }
}

module applicationInsights '../../modules/foundation/application-insights.bicep' = {
  name: 'stage01-applicationInsights'
  params: {
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.outputs.id
    name: applicationInsightsName
    tags: commonTags
  }
}

module appServicePlan '../../modules/web/app-service-plan.bicep' = {
  name: 'stage01-appServicePlan'
  params: {
    kind: 'linux'
    location: location
    name: appServicePlanName
    reserved: true
    skuName: 'B1'
    skuTier: 'Basic'
    tags: commonTags
  }
}

module webApp '../../modules/web/web-app.bicep' = {
  name: 'stage01-webApp'
  params: {
    appInsightsConnectionString: applicationInsights.outputs.connectionString
    appServicePlanId: appServicePlan.outputs.id
    appSettings: [
      {
        name: 'AZURE_REGION'
        value: location
      }
    ]
    location: location
    name: webAppName
    tags: commonTags
  }
}

module sqlLogicalServer '../../modules/data/sql-logical-server.bicep' = {
  name: 'stage01-sqlLogicalServer'
  params: {
    administratorLogin: sqlAdminLogin
    administratorLoginPassword: sqlAdminPassword
    location: location
    name: sqlServerName
    publicNetworkAccess: 'Enabled'
    allowAzureServices: true
    tags: commonTags
  }
}

module sqlDatabase '../../modules/data/sql-database.bicep' = {
  name: 'stage01-sqlDatabase'
  params: {
    location: location
    name: sqlDatabaseName
    skuName: 'Basic'
    skuTier: 'Basic'
    sqlServerName: sqlLogicalServer.outputs.name
    tags: commonTags
  }
}

@description('Name of the deployed web app.')
output webAppName string = webApp.outputs.name

@description('Default HTTPS URL of the deployed web app.')
output webAppUrl string = 'https://${webApp.outputs.defaultHostName}'

@description('Name of the deployed Application Insights component.')
output appInsightsName string = applicationInsights.outputs.name

@description('Fully qualified domain name of the deployed Azure SQL logical server.')
output sqlServerFqdn string = sqlLogicalServer.outputs.fullyQualifiedDomainName

@description('Name of the resource group hosting the Stage 1 MVP resources.')
output resourceGroupName string = resourceGroup().name
