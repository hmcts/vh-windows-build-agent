variable "resource_group_name" {
  type = string
}

variable "resource_prefix" {
  type = string
}

variable "secrets" {
  type = map(string)
}

variable "delegated_networks" {
  type = list(string)
}

variable "lock_down_network" {
  type    = bool
  description = "Specifiy whether network will be locked down or not"
  default = true
}
