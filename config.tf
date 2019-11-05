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
