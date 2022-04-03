param vnetName string
param functionAppSubnetName string
param functionAppName string

resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' existing = {
  name: vnetName
}

resource functionAppSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-06-01' existing = {
  parent: vnet
  name: functionAppSubnetName
}

resource functionApp 'Microsoft.Web/sites@2020-12-01' existing = {
  name: functionAppName
}

resource functionAppAttachSubnet 'Microsoft.Web/sites/networkConfig@2020-06-01' = {
  parent: functionApp
  name: 'virtualNetwork'
  properties: {
    subnetResourceId: functionAppSubnet.id
  }
}
