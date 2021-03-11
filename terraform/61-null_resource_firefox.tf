resource "null_resource" "firefox" {
  depends_on = [azurerm_virtual_machine.buildagent, azurerm_virtual_machine_extension.azuredevopsvmex]

  provisioner "remote-exec" {
    connection {
      type     = "winrm"
      user     = random_password.username.result
      password = random_password.password.result
      host     = azurerm_public_ip.buildagent.ip_address
      insecure = false
    }

    inline = [
      "powershell choco install firefox"
    ]

  }
}