data "azurerm_resource_group" "vh-core-infra" {
  name = var.resource_group_name
}

locals {
  environment = lookup(var.workspace_to_environment_map, terraform.workspace, "preview")
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "vh-core-infra-ht" {
  name                        = "${replace(var.resource_prefix, "-", "")}ht${local.environment}"
  resource_group_name         = data.azurerm_resource_group.vh-core-infra.name
  location                    = data.azurerm_resource_group.vh-core-infra.location
  enabled_for_disk_encryption = false
  tenant_id                   = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

  # vsts automation
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = "1fb13944-cfd1-44e2-96a4-9ee10a1932db"

    certificate_permissions = [
      "get",
    ]

    key_permissions = [
      "get",
    ]

    secret_permissions = [
      "get",
      "list",
      "set"
    ]
  }

  # vsts automation
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = "655eb910-cf45-403b-b2ff-d8ee40a5cd69"

    certificate_permissions = [
      "get",
    ]

    key_permissions = [
      "get",
    ]

    secret_permissions = [
      "get",
      "list",
      "set"
    ]
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

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

    storage_permissions = [
      "backup",
      "delete",
      "deletesas",
      "get",
      "getsas",
      "list",
      "listsas",
      "purge",
      "recover",
      "regeneratekey",
      "restore",
      "set",
      "setsas",
      "update"
    ]
  }

  network_acls {
    default_action = "Deny"
    bypass         = "None"
    ip_rules = [
    ]
    virtual_network_subnet_ids = values(var.delegated_networks)
  }
}

resource "azurerm_key_vault_secret" "app_id" {
  for_each = var.apps

  name         = "vh-${each.key}-appid"
  value        = each.value.application_id
  key_vault_id = azurerm_key_vault.vh-core-infra-ht.id
}

resource "azurerm_key_vault_secret" "app_secret" {
  for_each = var.apps

  name         = "vh-${each.key}-key"
  value        = each.value.secret
  key_vault_id = azurerm_key_vault.vh-core-infra-ht.id
}

resource "azurerm_key_vault_secret" "app_identifier" {
  for_each = var.apps

  name         = "vh-${each.key}-identifieruris"
  value        = each.value.url
  key_vault_id = azurerm_key_vault.vh-core-infra-ht.id
}

resource "azurerm_key_vault_secret" "app_name" {
  for_each = var.apps

  name         = "vh-${each.key}-appname"
  value        = each.value.url
  key_vault_id = azurerm_key_vault.vh-core-infra-ht.id
}
