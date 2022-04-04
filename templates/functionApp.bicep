/* Modules for Azure function App:
Resource group
Storage account
App service plan
App insights (optional but highly recommended)
Key Vault (optional)
Function App and its settings
*/

param functionAppAspName string
param functionAppName string
@description('Contains storage account API version, name and id to retrieve the connection string.')
param storageAccountDetails object

resource appServicePlanFunctionApp 'Microsoft.Web/serverfarms@2020-10-01' = {
  name: functionAppAspName
  location: resourceGroup().location
  sku:{
    name: 'P2V2'
    tier: 'Dynamic'
    size: 'P2V2'
  }
  kind:'linux'
  properties:{
    reserved:true
  }
}

var storageAccountConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${storageAccountDetails.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccountDetails.id, storageAccountDetails.apiVersion).keys[0].value}'

resource appServiceFunctionApp 'Microsoft.Web/sites@2020-10-01'= {
  name: functionAppName
  kind: 'functionapp'
  location: resourceGroup().location
  properties: {
    enabled:true
    serverFarmId: appServicePlanFunctionApp.id
    siteConfig:{
      linuxFxVersion: 'PYTHON|3.9'
      appSettings:[
        {
          name: 'AzureWebJobsStorage'
          value: storageAccountConnectionString
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'python'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
      ]
      cors:{
        allowedOrigins: [
          'https://portal.azure.com'
        ]
      }
    }
  }
}



// resource funcapp_appSettings 'Microsoft.Web/sites/config@2021-03-01' = {
//   name: '${appServiceFunctionApp.name}/appsettings'
//   properties: {
//     siteConfig:{
//       cors:{
//         allowedOrigins: [
//           'https://portal.azure.com'
//         ]
//       }
//     }
//   }
// }

// param location string

// param storage_account_name string

// param app_service_plan_name string

// param app_service_app_name string

// resource storage_account 'Microsoft.Storage/storageAccounts@2021-01-01' = {
//   name: storage_account_name
//   location: location
//   sku: {
//     name:'Standard_LRS'
//   }
//   kind: 'StorageV2'
// }

// resource app_service_plan 'Microsoft.Web/serverfarms@2020-10-01' = {
//   name: app_service_plan_name
//   location: location
//   sku:{
//     name:'Y1'
//     tier:'Dynamic'
//   }
//   kind:'linux'
//   properties:{
//     reserved:true
//   }

// }

// resource app_service_app 'Microsoft.Web/sites@2020-10-01'= {
//   name: app_service_app_name
//   kind: 'functionapp'
//   location: location
//   properties: {
//     enabled:true
//     serverFarmId: app_service_plan.id
//     siteConfig:{
//       linuxFxVersion: 'PYTHON|3.9'
//       appSettings:[
//         {
//           name: 'AzureWebJobsStorage'
//           value: 'DefaultEndpointsProtocol=https;AccountName=${storage_account.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storage_account.listKeys().keys[0].value}'
//         }
//         {
//           name: 'FUNCTIONS_WORKER_RUNTIME'
//           value: 'python'
//         }
//         {
//           name: 'FUNCTIONS_EXTENSION_VERSION'
//           value: '~4'
//         }
//         // {
//         //   name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
//         //   value: 'DefaultEndpointsProtocol=https;AccountName=${storage_account.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storage_account.listKeys().keys[0].value}'
//         // }
//       ]
//       cors:{
//         allowedOrigins: [
//           'https://portal.azure.com'
//         ]
//       }
//     }
//     // siteConfig:{
//     //   linuxFxVersion: 'python|3.9'
//     //   // azureStorageAccounts:storage_account
//     // }
//   }
// }

// // resource functionAppConfig 'Microsoft.Web/sites/config@2021-03-01'= {
// //   parent:app_service_app
// //   name: 'web'
// // }

// output app_service_app_host_name string = app_service_app.properties.defaultHostName
