terraform {
  backend "azurerm" {
    container_name = "tfstate"
    key            = "infra/vh-build-agent.tfstate"
  }

  required_version = ">= 0.12"
  required_providers {
    azurerm = ">= 1.36"
  }
}

provider "azurerm" {
  version = ">= 1.36.0"
  features {}
}
