locals {
  delegated_networks = [azurerm_subnet.buildagent.id]
  lock_down_network  = var.current_agent_pool == var.azdevops_agentpool
 }
 
 resource "azurerm_key_vault" "secrets" {
  name                        = replace(local.resource_prefix, "-", "")
  location                    = azurerm_resource_group.buildagent.location
  resource_group_name         = azurerm_resource_group.buildagent.name
  enabled_for_disk_encryption = false
  tenant_id                   = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

  # kv user identity
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_user_assigned_identity.kvuser.principal_id

    certificate_permissions = var.certificate_permissions
    key_permissions         = var.key_permissions
    secret_permissions      = var.secret_permissions

  }

  dynamic "access_policy" {
    for_each = data.azurerm_client_config.current.object_id != azurerm_user_assigned_identity.kvuser.principal_id ? [data.azurerm_client_config.current.object_id] : []

    content {
      tenant_id = data.azurerm_client_config.current.tenant_id
      object_id = access_policy.value

      certificate_permissions = var.certificate_permissions
      key_permissions         = var.key_permissions
      secret_permissions      = var.secret_permissions

    }
  }

  dynamic "network_acls" {
    for_each = local.lock_down_network ? [local.delegated_networks] : []

    content {
      default_action             = "Deny"
      bypass                     = ["None"]
      ip_rules                   = []
      virtual_network_subnet_ids = [network_acls.value]
    }
  }
}
