resource "azurerm_virtual_machine_extension" "azuredevopsvmex" {
  name                 = "AzureDevOpsAgent"
  virtual_machine_id   = azurerm_virtual_machine.buildagent.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  protected_settings = <<PROTECTED_SETTINGS
  {
  "storageAccountName": "${azurerm_storage_account.buildagent.name}",
  "storageAccountKey": "${azurerm_storage_account.buildagent.primary_access_key}",
  "fileUris": ["${azurerm_storage_blob.deployment_script.url}"],
  "commandToExecute": "${local.deployment_command} ${local.deployment_params}",
  "timestamp" : "12"
  }
PROTECTED_SETTINGS
}
