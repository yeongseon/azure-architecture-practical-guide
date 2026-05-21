@description('Name of the metric alert.')
param name string

@description('Description of the metric alert.')
param alertDescription string

@description('Resource ID of the target resource for the metric alert.')
param targetResourceId string

@description('Metric name monitored by the alert rule.')
param metricName string

@description('Comparison operator used by the alert rule.')
@allowed([
  'Equals'
  'GreaterThan'
  'GreaterThanOrEqual'
  'LessThan'
  'LessThanOrEqual'
])
param operator string

@description('Threshold value for the metric alert.')
param threshold int

@description('Resource ID of the action group invoked by the alert.')
param actionGroupId string

@description('Evaluation frequency for the metric alert.')
param evaluationFrequency string = 'PT5M'

@description('Window size used for the metric alert evaluation.')
param windowSize string = 'PT5M'

@description('Tags applied to the metric alert.')
param tags object = {}

resource metricAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: name
  location: 'global'
  tags: tags
  properties: {
    description: alertDescription
    severity: 3
    enabled: true
    scopes: [
      targetResourceId
    ]
    evaluationFrequency: evaluationFrequency
    windowSize: windowSize
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: '${metricName}-criterion'
          criterionType: 'StaticThresholdCriterion'
          metricName: metricName
          operator: operator
          threshold: threshold
          timeAggregation: 'Average'
        }
      ]
    }
    autoMitigate: true
    actions: [
      {
        actionGroupId: actionGroupId
      }
    ]
    targetResourceType: ''
    targetResourceRegion: ''
  }
}

@description('Resource ID of the metric alert.')
output id string = metricAlert.id
