resource "azurerm_virtual_machine" "buildagent" {
  name                = local.resource_prefix
  location            = azurerm_resource_group.buildagent.location
  resource_group_name = azurerm_resource_group.buildagent.name

  network_interface_ids            = [azurerm_network_interface.buildagent.id]
  vm_size                          = var.vm_size
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_os_disk {
    name              = local.resource_prefix
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
    computer_name  = replace(local.resource_prefix, "-", "")
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
    identity_ids = [azurerm_user_assigned_identity.kvuser.id]
  }
}