@description('Name of the Front Door profile.')
param name string

@description('Name of the Front Door endpoint.')
param endpointName string = name

@description('SKU for the Front Door profile.')
@allowed([
  'Standard_AzureFrontDoor'
  'Premium_AzureFrontDoor'
])
param skuName string = 'Standard_AzureFrontDoor'

@description('Name of the WAF policy.')
param wafPolicyName string = '${replace(name, '-', '')}waf'

@description('WAF policy mode.')
@allowed([
  'Detection'
  'Prevention'
])
param wafMode string = 'Prevention'

@description('Resource tags.')
param tags object = {}

resource profile 'Microsoft.Cdn/profiles@2023-05-01' = {
  name: name
  location: 'Global'
  tags: tags
  sku: {
    name: skuName
  }
}

resource endpoint 'Microsoft.Cdn/profiles/afdEndpoints@2023-05-01' = {
  parent: profile
  name: endpointName
  location: 'Global'
  properties: {
    enabledState: 'Enabled'
  }
}

resource wafPolicy 'Microsoft.Network/FrontDoorWebApplicationFirewallPolicies@2022-05-01' = {
  name: wafPolicyName
  location: 'Global'
  tags: tags
  sku: {
    name: skuName
  }
  properties: {
    policySettings: {
      enabledState: 'Enabled'
      mode: wafMode
    }
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: 'Microsoft_DefaultRuleSet'
          ruleSetVersion: '2.1'
          ruleSetAction: 'Block'
        }
      ]
    }
  }
}

resource securityPolicy 'Microsoft.Cdn/profiles/securityPolicies@2023-05-01' = {
  parent: profile
  name: '${name}-security-policy'
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

@description('Resource ID of the Front Door profile.')
output profileId string = profile.id

@description('Resource ID of the Front Door endpoint.')
output endpointId string = endpoint.id

@description('Host name of the Front Door endpoint.')
output endpointHostName string = endpoint.properties.hostName

@description('Resource ID of the WAF policy.')
output wafPolicyId string = wafPolicy.id
