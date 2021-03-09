terraform {
  required_version = ">= 0.12"
  backend "azurerm" {
    container_name = "tfstate"
    key            = "infra/vh-build-agent.tfstate"
  }
}

provider "azurerm" {
  version = ">= 1.36.0"
  features {}
}
