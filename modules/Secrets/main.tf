data "azurerm_resource_group" "secrets" {
  name = var.resource_group_name
}

data "azurerm_client_config" "current" {}

resource "azurerm_user_assigned_identity" "kvuser" {
  resource_group_name = data.azurerm_resource_group.secrets.name
  location            = data.azurerm_resource_group.secrets.location

  name = "${var.resource_prefix}-kvuser"
}

resource "azurerm_key_vault" "secrets" {
  name                        = replace(var.resource_prefix, "-", "")
  resource_group_name         = data.azurerm_resource_group.secrets.name
  location                    = data.azurerm_resource_group.secrets.location
  enabled_for_disk_encryption = false
  tenant_id                   = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

  # kv user identity
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_user_assigned_identity.kvuser.principal_id

    certificate_permissions = [
      "get",
      "list",
      "set"
    ]

    key_permissions = [
      "get",
      "list",
      "set"
    ]

    secret_permissions = [
      "get",
      "list",
      "set"
    ]
  }

  network_acls {
    default_action = "Deny"
    bypass         = "None"
    ip_rules = [
    ]
    virtual_network_subnet_ids = var.delegated_networks
  }
}

resource "azurerm_key_vault_secret" "secret" {
  for_each = var.secrets

  name         = each.key
  value        = each.value
  key_vault_id = azurerm_key_vault.secrets.id
}

output "kv_managed_identity" {
  value = azurerm_user_assigned_identity.kvuser
}
