@description('Name of the autoscale setting.')
param name string

@description('Azure region for the autoscale setting.')
param location string

@description('Resource ID of the target resource being autoscaled.')
param targetResourceId string

@description('Minimum instance count for autoscale.')
param minCapacity string = '1'

@description('Maximum instance count for autoscale.')
param maxCapacity string = '2'

@description('Default instance count for autoscale.')
param defaultCapacity string = '1'

@description('Resource ID used for the autoscale CPU metric source.')
param metricResourceId string

@description('Tags applied to the autoscale setting.')
param tags object = {}

resource autoscaleSetting 'Microsoft.Insights/autoscalesettings@2022-10-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    enabled: true
    name: name
    targetResourceUri: targetResourceId
    profiles: [
      {
        name: 'default-cpu-profile'
        capacity: {
          minimum: minCapacity
          maximum: maxCapacity
          default: defaultCapacity
        }
        rules: [
          {
            metricTrigger: {
              metricName: 'CpuPercentage'
              metricResourceUri: metricResourceId
              timeGrain: 'PT1M'
              statistic: 'Average'
              timeWindow: 'PT5M'
              timeAggregation: 'Average'
              operator: 'GreaterThan'
              threshold: 70
            }
            scaleAction: {
              direction: 'Increase'
              type: 'ChangeCount'
              value: '1'
              cooldown: 'PT5M'
            }
          }
          {
            metricTrigger: {
              metricName: 'CpuPercentage'
              metricResourceUri: metricResourceId
              timeGrain: 'PT1M'
              statistic: 'Average'
              timeWindow: 'PT5M'
              timeAggregation: 'Average'
              operator: 'LessThan'
              threshold: 30
            }
            scaleAction: {
              direction: 'Decrease'
              type: 'ChangeCount'
              value: '1'
              cooldown: 'PT5M'
            }
          }
        ]
      }
    ]
    notifications: []
  }
}

@description('Resource ID of the autoscale setting.')
output id string = autoscaleSetting.id
