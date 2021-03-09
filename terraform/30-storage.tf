resource "azurerm_storage_account" "buildagent" {
  name                = replace(var.resource_prefix, "-", "")
  resource_group_name = azurerm_resource_group.buildagent.name
  location            = azurerm_resource_group.buildagent.location

  account_tier              = "Standard"
  account_replication_type  = "LRS"
  account_kind              = "StorageV2"
  access_tier               = "Cool"
  enable_https_traffic_only = true

  dynamic "network_rules" {
    for_each = var.current_agent_pool == var.azdevops_agentpool ? [azurerm_subnet.buildagent.id] : []

    content {
      default_action             = "Deny"
      bypass                     = ["None"]
      virtual_network_subnet_ids = [network_rules.value]
    }
  }
}

resource "azurerm_advanced_threat_protection" "buildagent" {
  target_resource_id = azurerm_storage_account.buildagent.id
  enabled            = true
}

resource "azurerm_storage_container" "scripts" {
  name                  = "scripts"
  storage_account_name  = azurerm_storage_account.buildagent.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "deployment_script" {
  name                   = "Prepare-BuildAgent.ps1"
  storage_account_name   = azurerm_storage_account.buildagent.name
  storage_container_name = azurerm_storage_container.scripts.name
  type                   = "Block"
  source                 = "Prepare-BuildAgent.ps1"
  metadata = {
    md5 = filemd5("Prepare-BuildAgent.ps1")
  }
}
