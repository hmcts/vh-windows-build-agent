resource "azurerm_resource_group" "buildagent" {
  name     = local.resource_prefix
  location = var.location
  tags     = local.common_tags
}
