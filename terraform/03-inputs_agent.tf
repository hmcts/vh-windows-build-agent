variable "vm_size" {
  type        = string
  description = "Specifiy the size of the build machine the vm"
  default     = "Standard_D4s_v3"
}

variable "azdevops_url" {
  type        = string
  description = "Specify the Azure DevOps url e.g. https://dev.azure.com/hmctsreform"
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
