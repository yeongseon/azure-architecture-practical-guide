using './main.bicep'

param appBaseName = 'storefront'
param location = 'koreacentral'
param sqlAdministratorLogin = 'storefrontadmin'
param sqlAdministratorLoginPassword = readEnvironmentVariable('SQL_ADMIN_PASSWORD')
