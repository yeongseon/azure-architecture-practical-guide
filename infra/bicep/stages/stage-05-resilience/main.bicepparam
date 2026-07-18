using './main.bicep'

param appBaseName = 'storefront'
param location = 'koreacentral'
param secondaryLocation = 'japaneast'
param sqlAdministratorLogin = 'storefrontadmin'
param sqlAdministratorLoginPassword = readEnvironmentVariable('SQL_ADMIN_PASSWORD')
param sqlEntraAdminLogin = readEnvironmentVariable('SQL_ENTRA_ADMIN_LOGIN')
param sqlEntraAdminObjectId = readEnvironmentVariable('SQL_ENTRA_ADMIN_OBJECT_ID')
param alertEmailAddress = readEnvironmentVariable('ALERT_EMAIL_ADDRESS')
param autoscaleMaximumCapacity = 2
param failoverGracePeriodMinutes = 60
