terraform {
  backend "azurerm" {
    container_name = "tfstate"
    key            = "infra/vh-build-agent.tfstate"
  }
}

provider "azurerm" {
  version = ">= 1.36.0"
}

locals {
  environment   = lookup(var.workspace_to_environment_map, terraform.workspace, "dev")
  suffix        = "-${local.environment}"
  common_prefix = "vsts-agent"
  std_prefix    = "vh-${local.common_prefix}"
}

resource "azurerm_resource_group" "buildagent" {
  name     = "${local.std_prefix}${local.suffix}"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_virtual_network" "buildagent" {
  name                = "${local.std_prefix}${local.suffix}"
  resource_group_name = azurerm_resource_group.buildagent.name
  location            = azurerm_resource_group.buildagent.location

  address_space = ["10.254.0.248/29"]
}

resource "azurerm_subnet" "buildagent" {
  name                 = "${local.std_prefix}${local.suffix}"
  resource_group_name  = azurerm_resource_group.buildagent.name
  virtual_network_name = azurerm_virtual_network.buildagent.name

  address_prefix = cidrsubnet(azurerm_virtual_network.buildagent.address_space[0], 0, 0)

  service_endpoints = [
    "Microsoft.Web",
    "Microsoft.KeyVault",
    "Microsoft.Storage",
    "Microsoft.Sql"
  ]
}

resource "azurerm_public_ip" "buildagent" {
  name                = "${local.std_prefix}${local.suffix}"
  location            = azurerm_resource_group.buildagent.location
  resource_group_name = azurerm_resource_group.buildagent.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_security_group" "buildagent" {
  name                = "${local.std_prefix}${local.suffix}"
  location            = azurerm_resource_group.buildagent.location
  resource_group_name = azurerm_resource_group.buildagent.name
}

resource "azurerm_network_interface" "buildagent" {
  name                      = "${local.std_prefix}${local.suffix}"
  location                  = azurerm_resource_group.buildagent.location
  resource_group_name       = azurerm_resource_group.buildagent.name
  network_security_group_id = azurerm_network_security_group.buildagent.id

  ip_configuration {
    name                          = "${local.std_prefix}${local.suffix}"
    subnet_id                     = azurerm_subnet.buildagent.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.buildagent.id
  }
}

resource "azurerm_storage_account" "buildagent" {
  name                = replace("${local.std_prefix}${local.suffix}","-","")
  resource_group_name = azurerm_resource_group.buildagent.name
  location            = azurerm_resource_group.buildagent.location

  account_tier                      = "Standard"
  account_replication_type          = "LRS"
  account_kind                      = "StorageV2"
  access_tier                       = "Cool"
  enable_file_encryption            = true
  enable_https_traffic_only         = true
  enable_advanced_threat_protection = true

  network_rules {
    default_action             = "Deny"
    bypass                     = ["None"]
    virtual_network_subnet_ids = [var.build_agent_vnet, azurerm_subnet.buildagent.id]
  }
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
}

resource "random_password" "username" {
  length  = 12
  special = false
}

resource "random_password" "password" {
  length  = 32
  special = true
}

module Secrets {
  source = "./modules/Secrets"

  resource_group_name = azurerm_resource_group.buildagent.name
  resource_prefix     = "${local.std_prefix}${local.suffix}"
  secrets = {
    username = random_password.username.result
    password = random_password.password.result
  }
  delegated_networks = [var.build_agent_vnet, azurerm_subnet.buildagent.id]
}

resource "azurerm_virtual_machine" "buildagent" {
  name                = replace("${local.std_prefix}${local.suffix}","-","")
  location            = azurerm_resource_group.buildagent.location
  resource_group_name = azurerm_resource_group.buildagent.name

  network_interface_ids            = [azurerm_network_interface.buildagent.id]
  vm_size                          = var.vm_size
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_os_disk {
    name              = "${local.std_prefix}${local.suffix}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter-with-Containers"
    version   = "latest"
  }

  os_profile {
    computer_name  = "${local.std_prefix}${local.suffix}"
    admin_username = random_password.username.result
    admin_password = random_password.password.result
  }

  os_profile_windows_config {
    provision_vm_agent        = true
    enable_automatic_upgrades = true
    timezone                  = var.timezone
  }

  boot_diagnostics {
    enabled     = "true"
    storage_uri = azurerm_storage_account.buildagent.primary_blob_endpoint
  }

  identity {
    type         = "UserAssigned"
    identity_ids = concat(var.identities, [module.Secrets.kv_managed_identity.id])
  }
}

locals {
  deployment_command = "powershell.exe -ExecutionPolicy Unrestricted -File ./${azurerm_storage_blob.deployment_script.name}"
  deployment_params  = "-DevOpsUrl ${var.azdevops_url} -PAT ${var.azdevops_pat} -AgentPool ${var.azdevops_agentpool} -AgentName ${local.std_prefix}${local.suffix} -InstanceCount ${var.azdevops_agent_count}"
}

resource "azurerm_virtual_machine_extension" "azuredevopsvmex" {
  name                 = "AzureDevOpsAgent"
  location             = azurerm_resource_group.buildagent.location
  resource_group_name  = azurerm_resource_group.buildagent.name
  virtual_machine_name = azurerm_virtual_machine.buildagent.name
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  protected_settings = <<PROTECTED_SETTINGS
  {
  "storageAccountName": "${azurerm_storage_account.buildagent.name}",
  "storageAccountKey": "${azurerm_storage_account.buildagent.primary_access_key}",
  "fileUris": ["${azurerm_storage_blob.deployment_script.url}"],
  "commandToExecute": "${local.deployment_command} ${local.deployment_params}",
  "timestamp" : "12"
  }
PROTECTED_SETTINGS
}
