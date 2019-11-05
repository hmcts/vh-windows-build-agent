variable "workspace_to_environment_map" {
  type = "map"
  default = {
    Dev     = "dev"
    Pilot   = "pilot"
  }
}
