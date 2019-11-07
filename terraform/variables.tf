variable "workspace_to_environment_map" {
  type = map(string)
  default = {
    Dev   = "dev"
    Prod = "prod"
  }
}

variable "address_space" {
  type    = string
  default = "10.254.0.248/29"
}

locals {
  environment   = lookup(var.workspace_to_environment_map, terraform.workspace, "dev")
  suffix        = "-${local.environment}"
  common_prefix = "vsts-agent"
  std_prefix    = "vh-${local.common_prefix}"

  deployment_command = "powershell.exe -ExecutionPolicy Unrestricted -File ./${azurerm_storage_blob.deployment_script.name} -Verbose"
  deployment_params  = "-DevOpsUrl ${var.azdevops_url} -PAT ${var.azdevops_pat} -AgentPool ${var.azdevops_agentpool} -AgentName ${local.std_prefix}${local.suffix} -InstanceCount ${var.azdevops_agent_count}"
}
