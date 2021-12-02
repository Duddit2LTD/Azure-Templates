@description('Specify a unique name for your offer')
param mspOfferName string

@description('Name of the Managed Service Provider offering')
param mspOfferDescription string

@description('Specify the tenant id of the Managed Service Provider')
param managedByTenantId string

@description('Specify an array of objects, containing tuples of Azure Active Directory principalId, a Azure roleDefinitionId, and an optional principalIdDisplayName. The roleDefinition specified is granted to the principalId in the provider`s Active Directory and the principalIdDisplayName is visible to customers.')
param authorizations array

var mspRegistrationName = guid(mspOfferName)
var mspAssignmentName = guid(mspOfferName)

targetScope = 'subscription'

resource regDefinintion 'Microsoft.ManagedServices/registrationDefinitions@2019-09-01' = {
  name: mspRegistrationName
  properties: {
    registrationDefinitionName: mspOfferName
    description: mspOfferDescription
    managedByTenantId: managedByTenantId
    authorizations: authorizations
  }
}

resource regAssignment 'Microsoft.ManagedServices/registrationAssignments@2019-09-01' = {
  name: mspAssignmentName
  properties: {
    registrationDefinitionId: regDefinintion.id
  }
}
