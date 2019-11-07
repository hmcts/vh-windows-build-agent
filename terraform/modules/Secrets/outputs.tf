output "kv_managed_identity" {
  value = azurerm_user_assigned_identity.kvuser
  description = "The managed user identity object authorized to access keyvault"
}
