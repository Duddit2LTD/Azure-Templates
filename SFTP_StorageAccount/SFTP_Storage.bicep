param prefix string

resource sftp_storage_Acc 'Microsoft.Storage/storageAccounts@2021-06-01'= {
  name: '${prefix}storaccsftp01'
  location: 'UKSouth'
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}
