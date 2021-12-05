param prefix string
param AppGWRegionList array
param ResourceTags object


resource VNETs 'Microsoft.Network/virtualNetworks@2021-03-01'  = [for VNET in AppGWRegionList:{
  name: '${prefix}-VNET-${VNET.location}-${VNET.VersionNumber}'
  location: '${VNET.location}'
  tags: ResourceTags
  properties: {
    addressSpace: {
      addressPrefixes: [
        VNET.VNET_CIDR
      ]
    }
    subnets: [
      {
        name: '${prefix}-VNET-${VNET.location}-${VNET.VersionNumber}-AppGW-SN'
        properties: {
          addressPrefix: VNET.AppGWSN
          serviceEndpoints: [
            {
              service: 'microsoft.storage'
              locations: [
                VNET.location
              ]
            }
            {
              service: 'Microsoft.KeyVault'
              locations: [
                '*'
              ]
            }
          ]
        }
      }
    ]
  }

    

}]

resource PIPs 'Microsoft.Network/publicIPAddresses@2021-03-01' = [for pip in AppGWRegionList:{
  name: '${prefix}-ApGW_PIP-${pip.location}-${pip.VersionNumber}'
  location: pip.location
  tags: ResourceTags
  properties: {
    
    publicIPAllocationMethod: 'Static'
  }
  dependsOn: [
    
  ]
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
}]

resource AppGateways 'Microsoft.Network/applicationGateways@2021-03-01' = [for appgw in AppGWRegionList: {
  name: '${prefix}-AppGW-${appgw.location}-${appgw.VersionNumber}'
  location: '${appgw.location}'
  tags: ResourceTags
  dependsOn:[
    VNETs
    PIPs
  ]
 /*  identity: {
    type:'SystemAssigned'
  } */
  properties: {
    enableHttp2: true
    //enableFips: false

    sku: {
      name: appgw.SKU
      tier: appgw.SKU
      //capacity: 1
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
            id: '${resourceGroup().id}/providers/Microsoft.Network/virtualNetworks/${prefix}-VNET-${appgw.location}-${appgw.VersionNumber}/subnets/${prefix}-VNET-${appgw.location}-${appgw.VersionNumber}-AppGW-SN' //This string specifies the subnet ID ${prefix}-VNET-${VNET.location}-${VNET.VersionNumber}-AppGW-SN
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name:  'FE01'
        properties: {
        
          publicIPAddress: {
            id: '${resourceGroup().id}/providers/Microsoft.Network/publicIPAddresses/${prefix}-ApGW_PIP-${appgw.location}-${appgw.VersionNumber}'
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
        name: 'BE01'

        properties: {

          backendAddresses: [
            
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
        name: 'FE01'
        properties: {
          frontendIPConfiguration: {
            id: '${resourceGroup().id}/providers/Microsoft.Network/applicationGateways/${prefix}-AppGW-${appgw.location}-${appgw.VersionNumber}/frontendIPConfigurations/FE01'
          }
          frontendPort: {
            id: '${resourceGroup().id}/providers/Microsoft.Network/applicationGateways/${prefix}-AppGW-${appgw.location}-${appgw.VersionNumber}/frontendPorts/HTTP'
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
          priority: 10
          httpListener: {
            id: '${resourceGroup().id}/providers/Microsoft.Network/applicationGateways/${prefix}-AppGW-${appgw.location}-${appgw.VersionNumber}/httplisteners/FE01'
          }
          backendAddressPool: {
            id: '${resourceGroup().id}/providers/Microsoft.Network/applicationGateways/${prefix}-AppGW-${appgw.location}-${appgw.VersionNumber}/backendaddresspools/BE01'
          }
          backendHttpSettings: {
            id: '${resourceGroup().id}/providers/Microsoft.Network/applicationGateways/${prefix}-AppGW-${appgw.location}-${appgw.VersionNumber}/backendHttpSettingsCollection/BE_HTTP'
          }          
        }
      }
    ]
  }
}]  
