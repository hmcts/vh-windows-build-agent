locals {
  secrets = {
    username = random_password.username.result
    password = random_password.password.result
  }
}

resource "azurerm_key_vault_secret" "secret" {
  for_each = local.secrets

  name         = each.key
  value        = each.value
  key_vault_id = azurerm_key_vault.secrets.id
}
