param prefix string
param AppGWRegionList array

resource VNETs 'Microsoft.Network/virtualNetworks@2021-03-01' = [for VNET in AppGWRegionList:{
  name: '${prefix}-VNET${VNET.location}'
  location: '${VNET.location}'
  properties: {

    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    

}]

resource PIPs 'Microsoft.Network/publicIPAddresses@2021-03-01' = [for pip in AppGWRegionList:{
  name: '${prefix}-ApGW_PIP-${pip.location}-${pip.VersionNumber}'
  location: pip.location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
}]


resource AppGateways 'Microsoft.Network/applicationGateways@2021-03-01' = [for appgw in AppGWRegionList: {
  name: '${prefix}-AppGW-${appgw.location}-${appgw.VersionNumber}'
  location: '${appgw.location}'
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
    gatewayIPConfigurations: [
      {
        name: 'AppGatewayIPConfig'
        properties: {
          subnet: {
            id: 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx_AppGWSubnet' //This string specifies the subnet ID
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name:  'FE01'
        properties: {
        
          publicIPAddress: {
            id: '${prefix}-pip-${appgw.location}-${appgw.VersionNumber}'
          }
        
          
        }
        
      }
    ]
    frontendPorts: [
      {
        name: 'HTTP'
        properties: {
          port: 80
        }
        
      }
    ]
    backendAddressPools: [ 
      {
        name: '${prefix}-AppGW-${appgw.location}-${appgw.VersionNumber}-BE01'
        properties: {
          backendAddresses: [
            {
              
            }
          ]

        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'BE_HTTP'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: true
          requestTimeout: 20
        }
      }
    ]
    httpListeners: [
      {
        name: 'MultisiteListener'
        properties: {
          frontendIPConfiguration: {
            id: '/subscriptions/${subscription().id}/resourceGroups/${resourceGroup().id}/providers/Microsoft.Network/applicationGateways/${prefix}-AppGW-${appgw.location}-${appgw.VersionNumber}/frontendIPConfigurations/FE01'
          }
          frontendPort: {
            id: '/subscriptions/${subscription().id}/resourceGroups/${resourceGroup().id}/providers/Microsoft.Network/applicationGateways/${prefix}-AppGW-${appgw.location}-${appgw.VersionNumber}/frontendPorts/HTTP'
          }
          protocol: 'Http'

          hostNames: [
          
          ]
          requireServerNameIndication:false
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'Routing'
        properties: {
          httpListener: {
            id: '/subscriptions/${subscription().id}/resourceGroups/${resourceGroup().id}/providers/Microsoft.Network/applicationGateways/${prefix}-AppGW-${appgw.location}-${appgw.VersionNumber}/httplisteners/-FE01'
          }
          backendAddressPool: {
            id: '/subscriptions/${subscription().id}/resourceGroups/${resourceGroup().id}/providers/Microsoft.Network/applicationGateways/${prefix}-AppGW-${appgw.location}-${appgw.VersionNumber}/backendaddresspools/-BE01'
          }
          backendHttpSettings: {
            id: '/subscriptions/${subscription().id}/resourceGroups/${resourceGroup().id}/providers/Microsoft.Network/applicationGateways/${prefix}-AppGW-${appgw.location}-${appgw.VersionNumber}/backendHttpSettingsCollection/-BE_HTTP'
          }
          priority: 10
          
        }
      }
      
    ]
  }
}]
