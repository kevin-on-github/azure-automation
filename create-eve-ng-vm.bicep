param location string = resourceGroup().location
param networkInterfaceName string = '${resourceGroup().name}-nic'
param networkSecurityGroupName string = '${resourceGroup().name}-nsg'
param networkSecurityGroupRules array = [
  {
    name: 'SSH'
    properties: {
      priority: 300
      protocol: 'TCP'
      access: 'Allow'
      direction: 'Inbound'
      sourceAddressPrefix: '*'
      sourcePortRange: '*'
      destinationAddressPrefix: '*'
      destinationPortRange: '22'
    }
  } 
  {
    name: 'EVE-NG-80'
      properties: {
        priority: 310
        protocol: 'TCP'
        access: 'Allow'
        direction: 'Inbound'
        sourceAddressPrefix: '*'
        sourcePortRange: '*'
        destinationAddressPrefix: '*'
        destinationPortRange: '80'
      }
    }
  {
  name: 'EVE-NG-NODES'
    properties: {
      priority: 320
      protocol: 'TCP'
      access: 'Allow'
      direction: 'Inbound'
      sourceAddressPrefix: '*'
      sourcePortRange: '*'
      destinationAddressPrefix: '*'
      destinationPortRange: '32768-33000'
    }
  }
]
param subnetName string = 'default'
param virtualNetworkName string = '${resourceGroup().name}-vnet'
param addressPrefixes array = [
  '10.0.0.0/24'
]
param subnets array = [
  {
    name: 'default'
    properties: {
      addressPrefix: '10.0.0.0/24'
    }
  }
]
param publicIpAddressName string = '${resourceGroup().name}-ip'
param publicIpAddressType string = 'Dynamic'
param publicIpAddressSku string = 'Basic'
param virtualMachineName string = resourceGroup().name
param virtualMachineComputerName string = resourceGroup().name
// param virtualMachineRG string = resourceGroup().name
param osDiskType string = 'StandardSSD_LRS'
param virtualMachineSize string = 'Standard_D2s_v3'
param adminUsername string


@secure()
param adminPassword string

var nsgId = resourceId(resourceGroup().name, 'Microsoft.Network/networkSecurityGroups', networkSecurityGroupName)
var vnetId = resourceId(resourceGroup().name, 'Microsoft.Network/virtualNetworks', virtualNetworkName)
var subnetRef = '${vnetId}/subnets/${subnetName}'

resource networkInterfaceName_resource 'Microsoft.Network/networkInterfaces@2018-10-01' = {
  name: networkInterfaceName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetRef
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: resourceId(resourceGroup().name, 'Microsoft.Network/publicIpAddresses', publicIpAddressName)
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsgId
    }
  }
  dependsOn: [
    networkSecurityGroupName_resource
    virtualNetworkName_resource
    publicIpAddressName_resource
  ]
}

resource networkSecurityGroupName_resource 'Microsoft.Network/networkSecurityGroups@2019-02-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: networkSecurityGroupRules
  }
}

resource virtualNetworkName_resource 'Microsoft.Network/virtualNetworks@2019-09-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
    subnets: subnets
  }
}

resource publicIpAddressName_resource 'Microsoft.Network/publicIpAddresses@2019-02-01' = {
  name: publicIpAddressName
  location: location
  sku: {
    name: publicIpAddressSku
  }

  properties: {
    publicIPAllocationMethod: publicIpAddressType
  }
}

resource virtualMachineName_resource 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: virtualMachineName
  location: location

  properties: {
    hardwareProfile: {
      vmSize: virtualMachineSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'fromImage'
        managedDisk: {
          storageAccountType: osDiskType
        }
      }
      imageReference: {
        publisher: 'canonical'
        offer: '0001-com-ubuntu-server-focal'
        sku: '20_04-lts'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterfaceName_resource.id
        }
      ]
    }
    securityProfile: {
    }
    osProfile: {
      computerName: virtualMachineComputerName
      adminUsername: adminUsername
      adminPassword: adminPassword
      linuxConfiguration: {
        patchSettings: {
          patchMode: 'ImageDefault'
        }
      }
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}


