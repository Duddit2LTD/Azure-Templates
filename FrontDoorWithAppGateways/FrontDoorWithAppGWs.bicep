param prefix string
param AppGWRegionList array


resource PIPs 'Microsoft.Network/publicIPAddresses@2021-03-01' = [for pip in AppGWRegionList:{
  name: '${prefix}-pip-${pip.location}-${pip.RegionNumber}'
  location: pip.location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
}]


resource AppGateways 'Microsoft.Network/applicationGateways@2021-03-01' = [for appgw in AppGWRegionList: {
  name: '${prefix}-AppGW-${appgw.location}-${appgw.RegionNumber}'
  location: '${appgw.location}'
  tags: {
    
  }
  identity: {
    type:'SystemAssigned'
  }
  properties: {
    enableHttp2: true
    enableFips: false
    sku: {
      name: appgw.SKU
      tier: appgw.SKU
      capacity: 1
    }
    webApplicationFirewallConfiguration: {
      enabled: true
      firewallMode: 'Detection' 
      ruleSetType: 'OWASP'
      ruleSetVersion: '3.2'
    }
    autoscaleConfiguration: {
      minCapacity: 0
      maxCapacity: 2
    }
    frontendIPConfigurations: [
      {
        name:  'FE01'
        properties: {
        
          publicIPAddress: {
            id: ''
          }
          
        }
        
      }
    ]
    frontendPorts: [
      {
        
      }
    ]
    backendAddressPools: [ 
      {
        name: '${prefix}-AppGW-${appgw.location}-${appgw.RegionNumber}-BE01'
        properties: {
          backendAddresses: [
            {
              
            }
          ]
        }
      }
    ]

  }

}]

