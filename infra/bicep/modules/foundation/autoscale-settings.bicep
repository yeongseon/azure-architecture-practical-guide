@description('Name of the autoscale setting.')
param name string

@description('Azure region for the autoscale setting.')
param location string = resourceGroup().location

@description('Resource ID of the target resource to scale, for example an App Service plan.')
param targetResourceId string

@description('Minimum instance count.')
param minimumCapacity int = 1

@description('Maximum instance count.')
param maximumCapacity int = 10

@description('Default instance count when no rule applies.')
param defaultCapacity int = 1

@description('Metric evaluated for scaling decisions.')
param metricName string = 'CpuPercentage'

@description('Metric namespace of the target resource.')
param metricNamespace string = 'Microsoft.Web/serverfarms'

@description('Scale-out threshold. Exceeding this adds an instance.')
param scaleOutThreshold int = 70

@description('Scale-in threshold. Falling below this removes an instance.')
param scaleInThreshold int = 30

@description('Resource tags.')
param tags object = {}

resource autoscale 'Microsoft.Insights/autoscaleSettings@2022-10-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    enabled: true
    targetResourceUri: targetResourceId
    profiles: [
      {
        name: 'Default profile'
        capacity: {
          minimum: string(minimumCapacity)
          maximum: string(maximumCapacity)
          default: string(defaultCapacity)
        }
        rules: [
          {
            metricTrigger: {
              metricName: metricName
              metricNamespace: metricNamespace
              metricResourceUri: targetResourceId
              timeGrain: 'PT1M'
              statistic: 'Average'
              timeWindow: 'PT5M'
              timeAggregation: 'Average'
              operator: 'GreaterThan'
              threshold: scaleOutThreshold
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
              metricName: metricName
              metricNamespace: metricNamespace
              metricResourceUri: targetResourceId
              timeGrain: 'PT1M'
              statistic: 'Average'
              timeWindow: 'PT5M'
              timeAggregation: 'Average'
              operator: 'LessThan'
              threshold: scaleInThreshold
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
  }
}

@description('Resource ID of the autoscale setting.')
output id string = autoscale.id

@description('Name of the autoscale setting.')
output name string = autoscale.name
