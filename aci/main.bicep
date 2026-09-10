param prefix string = 'tp104'
param location string = resourceGroup().location
param cpuCores string = '0.5'
param memoryInGb string = '1.0'

var dnsLabel = '${prefix}-aci-${uniqueString(resourceGroup().id)}'
var containerGroupName = '${prefix}-cg'

resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2023-05-01' = {
  name: containerGroupName
  location: location
  properties: {
    osType: 'Linux'
    ipAddress: {
      type: 'Public'
      dnsNameLabel: dnsLabel
      ports: [
        {
          port: 80
          protocol: 'TCP'
        }
      ]
    }
    containers: [
      {
        name: 'web'
        properties: {
          image: 'mcr.microsoft.com/azuredocs/aci-helloworld:latest'
          ports: [
            {
              port: 80
            }
          ]
          resources: {
            requests: {
              cpu: json(cpuCores)
              memoryInGB: json(memoryInGb)
            }
          }
        }
      }
      {
        name: 'sidecar'
        properties: {
          image: 'alpine:latest'
          command: [
            '/bin/sh'
            '-c'
            'while true; do echo "$(date) - Sidecar heart-beat active"; sleep 30; done'
          ]
          resources: {
            requests: {
              cpu: json('0.25')
              memoryInGB: json('0.25')
            }
          }
        }
      }
    ]
  }
}

output fqdn string = containerGroup.properties.ipAddress.fqdn
output containerGroupName string = containerGroup.name
