resource "azurerm_user_assigned_identity" "kvuser" {
  location            = azurerm_resource_group.buildagent.location
  resource_group_name = azurerm_resource_group.buildagent.name

  name = "${var.resource_prefix}-kvuser"
}
