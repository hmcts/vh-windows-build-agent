variable "scertificate_permissions" {
  description = "The permissions (list) for the creating principal accessing certifictes."
  default = [
    "backup",
    "create",
    "delete",
    "deleteissuers",
    "get",
    "getissuers",
    "import",
    "list",
    "listissuers",
    "managecontacts",
    "manageissuers",
    "purge",
    "recover",
    "restore",
    "setissuers",
    "update"
  ]
}

variable "key_permissions" {
  description = "The permissions (list) for the creating principal accessing keys."
  default = [
    "backup",
    "create",
    "decrypt",
    "delete",
    "encrypt",
    "get",
    "import",
    "list",
    "purge",
    "recover",
    "restore",
    "sign",
    "unwrapKey",
    "update",
    "verify",
    "wrapKey"
  ]
}


variable "secret_permissions" {
  description = "The permissions (list) for the creating principal accessing secrets."
  default = [
    "backup",
    "delete",
    "get",
    "list",
    "purge",
    "recover",
    "restore",
    "set"
  ]
}
