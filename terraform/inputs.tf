variable "location" {
  type        = string
  description = "Specifiy location to which all resources will be deployed"
  default     = "ukwest"
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
  type        = string
  description = "Specifiy timezone set within the guest of the vm"
  default     = "GMT Standard Time"
}

variable "vm_size" {
  type        = string
  description = "Specifiy the size of the build machine the vm"
  default     = "Standard_D4s_v3"
}

variable "current_agent_pool" {
  type        = string
  description = "Specifiy the current agent pool in order that the network rules can be disabled or not"
  default     = ""
}
