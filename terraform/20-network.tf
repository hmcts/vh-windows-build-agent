resource "azurerm_virtual_network" "buildagent" {
  name                = local.resource_prefix
  resource_group_name = azurerm_resource_group.buildagent.name
  location            = azurerm_resource_group.buildagent.location

  address_space = [var.address_space]
}

resource "azurerm_subnet" "buildagent" {
  name                 = local.resource_prefix
  resource_group_name  = azurerm_resource_group.buildagent.name
  virtual_network_name = azurerm_virtual_network.buildagent.name

  address_prefixes = [cidrsubnet(azurerm_virtual_network.buildagent.address_space[0], 0, 0)]

  service_endpoints = [
    "Microsoft.Web",
    "Microsoft.KeyVault",
    "Microsoft.Storage",
    "Microsoft.Sql"
  ]
}

resource "azurerm_public_ip" "buildagent" {
  name                = local.resource_prefix
  location            = azurerm_resource_group.buildagent.location
  resource_group_name = azurerm_resource_group.buildagent.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_security_group" "buildagent" {
  name                = local.resource_prefix
  location            = azurerm_resource_group.buildagent.location
  resource_group_name = azurerm_resource_group.buildagent.name

    security_rule {
      name                       = "WinRM"
      priority                   = 1001
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "5985"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
}

resource "azurerm_network_interface" "buildagent" {
  name                = local.resource_prefix
  location            = azurerm_resource_group.buildagent.location
  resource_group_name = azurerm_resource_group.buildagent.name

  ip_configuration {
    name                          = local.resource_prefix
    subnet_id                     = azurerm_subnet.buildagent.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.buildagent.id
  }
}

resource "azurerm_network_interface_security_group_association" "buildagent" {
  network_interface_id      = azurerm_network_interface.buildagent.id
  network_security_group_id = azurerm_network_security_group.buildagent.id
}
