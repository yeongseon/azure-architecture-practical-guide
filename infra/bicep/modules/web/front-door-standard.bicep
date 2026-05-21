@description('Name of the Azure Front Door profile.')
param name string

@description('Location for the Azure Front Door resources. Use global.')
@allowed([
  'global'
])
param location string = 'global'

@description('SKU name for the Azure Front Door profile.')
param skuName string = 'Standard_AzureFrontDoor'

@description('Name of the Azure Front Door endpoint.')
param endpointName string

@description('Origin host name backing the Azure Front Door route.')
param originHostName string

@description('Name of the Azure Front Door origin group.')
param originGroupName string

@description('Name of the Azure Front Door route.')
param routeName string

@description('Health probe path for the Azure Front Door origin group.')
param healthProbePath string = '/healthz'

@description('Name of the Front Door Web Application Firewall policy.')
param wafPolicyName string

@description('Mode for the Web Application Firewall policy.')
@allowed([
  'Detection'
  'Prevention'
])
param wafMode string = 'Prevention'

@description('Tags applied to the Azure Front Door profile and WAF policy.')
param tags object = {}

var originName = 'primary-origin'
var securityPolicyName = '${endpointName}-waf-policy'

resource profile 'Microsoft.Cdn/profiles@2024-02-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: skuName
  }
}

resource endpoint 'Microsoft.Cdn/profiles/afdEndpoints@2024-02-01' = {
  parent: profile
  name: endpointName
  location: location
  properties: {
    enabledState: 'Enabled'
  }
}

resource originGroup 'Microsoft.Cdn/profiles/originGroups@2024-02-01' = {
  parent: profile
  name: originGroupName
  properties: {
    healthProbeSettings: {
      probePath: healthProbePath
      probeRequestType: 'GET'
      probeProtocol: 'Https'
      probeIntervalInSeconds: 120
    }
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
      additionalLatencyInMilliseconds: 50
    }
    sessionAffinityState: 'Disabled'
  }
}

resource origin 'Microsoft.Cdn/profiles/originGroups/origins@2024-02-01' = {
  parent: originGroup
  name: originName
  properties: {
    hostName: originHostName
    httpPort: 80
    httpsPort: 443
    originHostHeader: originHostName
    priority: 1
    weight: 1000
    enabledState: 'Enabled'
    enforceCertificateNameCheck: true
  }
}

resource route 'Microsoft.Cdn/profiles/afdEndpoints/routes@2024-02-01' = {
  parent: endpoint
  name: routeName
  properties: {
    originGroup: {
      id: originGroup.id
    }
    supportedProtocols: [
      'Http'
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    forwardingProtocol: 'HttpsOnly'
    httpsRedirect: 'Enabled'
    linkToDefaultDomain: 'Enabled'
    enabledState: 'Enabled'
    originPath: ''
  }
}

resource wafPolicy 'Microsoft.Network/FrontDoorWebApplicationFirewallPolicies@2024-02-01' = {
  name: wafPolicyName
  location: location
  tags: tags
  properties: {
    policySettings: {
      enabledState: 'Enabled'
      mode: wafMode
      customBlockResponseStatusCode: 403
      customBlockResponseBody: null
      requestBodyCheck: 'Enabled'
    }
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: 'DefaultRuleSet'
          ruleSetVersion: '1.0'
        }
      ]
    }
  }
}

resource securityPolicy 'Microsoft.Cdn/profiles/securityPolicies@2024-02-01' = {
  parent: profile
  name: securityPolicyName
  properties: {
    parameters: {
      type: 'WebApplicationFirewall'
      wafPolicy: {
        id: wafPolicy.id
      }
      associations: [
        {
          domains: [
            {
              id: endpoint.id
            }
          ]
          patternsToMatch: [
            '/*'
          ]
        }
      ]
    }
  }
}

@description('Resource ID of the Azure Front Door profile.')
output profileId string = profile.id

@description('Hostname of the Azure Front Door endpoint.')
output endpointHostName string = endpoint.properties.hostName

@description('Resource ID of the Web Application Firewall policy.')
output wafPolicyId string = wafPolicy.id
