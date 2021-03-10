resource "null_resource" "chocolatey" {
  depends_on = [azurerm_virtual_machine.buildagent, azurerm_virtual_machine_extension.azuredevopsvmex]
  # triggers = {
  #   always_run = timestamp()
  # }
  provisioner "remote-exec" {
    connection {
      type     = "winrm"
      user     = random_password.username.result
      password = random_password.password.result
      host     = azurerm_public_ip.buildagent.ip_address
      insecure = false
    }

    inline = [
      "powershell Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"
    ]

  }
}