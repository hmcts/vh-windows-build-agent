variable "workspace_to_environment_map" {
  type = map(string)
  default = {
    Dev   = "dev"
    Pilot = "pilot"
  }
}
