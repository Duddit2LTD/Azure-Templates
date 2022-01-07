param prefix string
param location string
param VNET_CIDR string
param VPN object
param PIP object
param ResourceTags object
param LocalGW object


//list of vnets that need to peer to the Gateway_Vnet. To be used in a looping module
var peerings = [
  {
    name: 'samplevnet01'
  }

  {
    name: 'samplevnet02'
  }

]
  

resource peering 


resource Gateway_Vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: '${prefix}-GWVnet'
  location: location
  tags: ResourceTags
  properties: {
    addressSpace: {
      addressPrefixes: [
        '${VNET_CIDR}.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: '${VNET_CIDR}.0.0/24'
        }
      }
    ]
  } 
}

resource VPN_PIP 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: '${prefix}${PIP.PIP_Name}'
  location: location
  tags: ResourceTags
  properties: {
    publicIPAllocationMethod: PIP.publicIPAllocationMethod
  }
  sku: {
    name: PIP.SKU_Name
    tier: PIP.SKU_Tier
  }
  


}

resource LocalGateway 'Microsoft.Network/localNetworkGateways@2021-05-01' = {
  name: '${prefix}${LocalGW.name}'
  location: location
  tags: ResourceTags
  properties: {
    gatewayIpAddress: LocalGW.PIP
    localNetworkAddressSpace: {
      addressPrefixes: [
        LocalGW.AddressSpace
      ]
    }
  }
}



resource VPNGateway 'Microsoft.Network/virtualNetworkGateways@2021-05-01' = {
  name: '${prefix}-VPNGateway'
  location: location
  tags: ResourceTags
  dependsOn: [
    VPN_PIP
    Gateway_Vnet
  ]
  
  properties: {
    gatewayType: 'Vpn'
    vpnType: VPN.vpnType
    vpnGatewayGeneration: VPN.vpnGatewayGeneration
    sku: {
      name: VPN.SKU_Name
      tier: VPN.SKU_Tier
    }

    ipConfigurations: [
      {
        name: 'default'
        properties: {
          privateIPAllocationMethod: VPN.privateIPAllocationMethod
          subnet: {
            id: '${resourceGroup().id}/providers/Microsoft.Network/virtualNetworks/${prefix}-GWVnet/subnets/GatewaySubnet'
          }
          publicIPAddress: {
            id: '${resourceGroup().id}/providers/Microsoft.Network/publicIPAddresses/${prefix}${PIP.PIP_Name}'
          }
        }
      }
    ]
    
    
  }
}
