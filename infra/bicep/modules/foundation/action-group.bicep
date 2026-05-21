type emailReceiver = {
  name: string
  emailAddress: string
}

@description('Name of the Azure Monitor action group.')
param name string

@description('Short name for notifications. Maximum 12 characters.')
@maxLength(12)
param shortName string

@description('Email receivers included in the action group.')
param emailReceivers emailReceiver[]

@description('Tags applied to the action group.')
param tags object = {}

resource actionGroup 'Microsoft.Insights/actionGroups@2023-01-01' = {
  name: name
  location: 'global'
  tags: tags
  properties: {
    enabled: true
    groupShortName: shortName
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
