@description('Name of the metric alert rule.')
param name string

@description('Description of what the alert monitors.')
param alertDescription string = ''

@description('Resource ID of the target resource being monitored.')
param targetResourceId string

@description('Metric namespace of the target resource, for example Microsoft.Web/sites.')
param metricNamespace string

@description('Name of the metric to evaluate.')
param metricName string

@description('Comparison operator for the threshold.')
@allowed([
  'GreaterThan'
  'GreaterThanOrEqual'
  'LessThan'
  'LessThanOrEqual'
])
param operator string = 'GreaterThan'

@description('Aggregation applied to the metric before comparison.')
@allowed([
  'Average'
  'Minimum'
  'Maximum'
  'Total'
  'Count'
])
param timeAggregation string = 'Average'

@description('Threshold value that triggers the alert.')
param threshold int

@description('Alert severity, 0 (critical) to 4 (verbose).')
@allowed([
  0
  1
  2
  3
  4
])
param severity int = 3

@description('How often the rule evaluates, ISO 8601 duration.')
param evaluationFrequency string = 'PT5M'

@description('Time window over which the metric is aggregated, ISO 8601 duration.')
param windowSize string = 'PT15M'

@description('Resource ID of the action group to notify. Empty disables notification.')
param actionGroupId string = ''

@description('Resource tags.')
param tags object = {}

resource metricAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: name
  location: 'global'
  tags: tags
  properties: {
    description: alertDescription
    severity: severity
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
          name: 'Metric1'
          metricNamespace: metricNamespace
          metricName: metricName
          operator: operator
          timeAggregation: timeAggregation
          threshold: threshold
          criterionType: 'StaticThresholdCriterion'
        }
      ]
    }
    actions: empty(actionGroupId) ? [] : [
      {
        actionGroupId: actionGroupId
      }
    ]
  }
}

@description('Resource ID of the metric alert.')
output id string = metricAlert.id

@description('Name of the metric alert.')
output name string = metricAlert.name
