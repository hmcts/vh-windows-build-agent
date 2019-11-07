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
      "backup",
      "create",
      "delete",
      "deleteissuers",
      "get",
      "getissuers",
      "import",
      "list",
      "listissuers",
      "managecontacts",
      "manageissuers",
      "purge",
      "recover",
      "restore",
      "setissuers",
      "update"
    ]

    key_permissions = [
      "backup",
      "create",
      "decrypt",
      "delete",
      "encrypt",
      "get",
      "import",
      "list",
      "purge",
      "recover",
      "restore",
      "sign",
      "unwrapKey",
      "update",
      "verify",
      "wrapKey"
    ]

    secret_permissions = [
      "backup",
      "delete",
      "get",
      "list",
      "purge",
      "recover",
      "restore",
      "set"
    ]
  }

  dynamic "access_policy" {
    for_each = data.azurerm_client_config.current.object_id != azurerm_user_assigned_identity.kvuser.principal_id ? [data.azurerm_client_config.current.object_id] : []

    content {
      tenant_id = data.azurerm_client_config.current.tenant_id
      object_id = each.value

      certificate_permissions = [
        "backup",
        "create",
        "delete",
        "deleteissuers",
        "get",
        "getissuers",
        "import",
        "list",
        "listissuers",
        "managecontacts",
        "manageissuers",
        "purge",
        "recover",
        "restore",
        "setissuers",
        "update"
      ]

      key_permissions = [
        "backup",
        "create",
        "decrypt",
        "delete",
        "encrypt",
        "get",
        "import",
        "list",
        "purge",
        "recover",
        "restore",
        "sign",
        "unwrapKey",
        "update",
        "verify",
        "wrapKey"
      ]

      secret_permissions = [
        "backup",
        "delete",
        "get",
        "list",
        "purge",
        "recover",
        "restore",
        "set"
      ]
    }
  }

  dynamic "network_acls" {
    for_each = var.current_agent_pool == var.azdevops_agentpool ? [var.delegated_networks] : []

    content {
      default_action = "Deny"
      bypass         = ["None"]
      ip_rules = [
      ]
      virtual_network_subnet_ids = [each.value]
    }
  }
}

resource "azurerm_key_vault_secret" "secret" {
  for_each = var.secrets

  name         = each.key
  value        = each.value
  key_vault_id = azurerm_key_vault.secrets.id
}
