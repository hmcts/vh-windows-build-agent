variable "workspace_to_environment_map" {
  type = map(string)
  default = {
    Dev  = "dev"
    Prod = "prod"
  }
}

variable "location" {
  type        = string
  description = "Specifiy location to which all resources will be deployed"
  default     = "ukwest"
}

variable "timezone" {
  type        = string
  description = "Specifiy timezone set within the guest of the vm"
  default     = "GMT Standard Time"
}

locals {
  environment     = lookup(var.workspace_to_environment_map, terraform.workspace, "dev")
  suffix          = "-${local.environment}"
  common_prefix   = "vsts-agent"
  std_prefix      = "vh-${local.common_prefix}"
  resource_prefix = "${local.std_prefix}${local.suffix}"

  deployment_command = "powershell.exe -ExecutionPolicy Unrestricted -File ./${azurerm_storage_blob.deployment_script.name} -Verbose"
  deployment_params  = "-DevOpsUrl ${var.azdevops_url} -PAT ${var.azdevops_pat} -AgentPool ${var.azdevops_agentpool} -AgentName ${local.std_prefix}${local.suffix} -InstanceCount ${var.azdevops_agent_count}"
}

locals {
  common_tags = {
    "managedBy"          = "Reform Visual Hearings"
    "solutionOwner"      = ""
    "activityName"       = "Image Deployment"
    "dataClassification" = "Internal"
    "automation"         = "terraform"
    "costCentre"         = "10245117" // until we get a better one, this is the generic cft contingency one
    "environment"        = lookup(var.workspace_to_environment_map, terraform.workspace, "preview")
    "criticality"        = "Medium"
  }
}
