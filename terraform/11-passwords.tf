resource "random_password" "username" {
  length  = 12
  special = false
}

resource "random_password" "password" {
  length           = 32
  special          = true
  override_special = "!@#$%&"
}
