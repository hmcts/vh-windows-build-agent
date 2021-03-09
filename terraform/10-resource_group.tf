resource "azurerm_resource_group" "buildagent" {
  name     = var.resource_prefix
  location = var.location
  tags     = local.common_tags
}
