param prefix string
param location string



resource Gateway_Vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: '${prefix}-GWVnet'
  location: location
  properties: {
    
  } 
}

resource VPN_PIP 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: '${prefix}-VPN-PIP'
  location: location
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  zones: [
    '1'
    '2'
    '3'
  ]


}

resource VPNGateway 'Microsoft.Network/vpnGateways@2021-05-01' = {
  name: '${prefix}-VPNGateway'
  location: location
  dependsOn: [
    VPN_PIP
    Gateway_Vnet
  ]
  
  properties: {
    
  }
}
