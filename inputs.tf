variable "location" {
  type    = string
  default = "ukwest"
}

variable "identities" {
  type    = list(string)
  default = []
}

variable "azdevops_url" {
  type        = string
  description = "Specify the Azure DevOps url e.g. https://dev.azure.com/rdbartram"
}

variable "azdevops_pat" {
  type        = string
  description = "Provide a Personal Access Token (PAT) for Azure DevOps"
}

variable "azdevops_agentpool" {
  type        = string
  description = "Specify the name of the agent pool - must exist before"
}

variable "azdevops_agent_count" {
  type        = number
  description = "Specifiy number of agent instances to deploy on the vm"
  default     = 4
}

variable "timezone" {
  type    = string
  default = "Central European Standard Time"
}

variable "vm_size" {
  type    = string
  default = "Standard_DS3_v2"
}

variable "build_agent_vnet" {
  type    = string
  default = "/subscriptions/705b2731-0e0b-4df7-8630-95f157f0a347/resourceGroups/vh-devtestlabs-dev/providers/Microsoft.Network/virtualNetworks/Dtlvh-devtestlabs-dev/subnets/Dtlvh-devtestlabs-devSubnet"
}
