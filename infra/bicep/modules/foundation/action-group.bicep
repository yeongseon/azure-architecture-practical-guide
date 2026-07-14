@description('Name of the action group.')
param name string

@description('Short name (max 12 characters) shown in notifications.')
@maxLength(12)
param groupShortName string

@description('Email receivers. Each item requires a name and emailAddress.')
param emailReceivers array = []

@description('Enable the action group.')
param enabled bool = true

@description('Resource tags.')
param tags object = {}

resource actionGroup 'Microsoft.Insights/actionGroups@2023-01-01' = {
  name: name
  location: 'Global'
  tags: tags
  properties: {
    groupShortName: groupShortName
    enabled: enabled
    emailReceivers: [for receiver in emailReceivers: {
      name: receiver.name
      emailAddress: receiver.emailAddress
      useCommonAlertSchema: true
    }]
  }
}

@description('Resource ID of the action group.')
output id string = actionGroup.id

@description('Name of the action group.')
output name string = actionGroup.name
