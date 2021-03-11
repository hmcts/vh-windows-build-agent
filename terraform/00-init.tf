terraform {
  required_version = ">= 0.12"
  backend "azurerm" {
    container_name = "tfstate"
    key            = "infra/vh-build-agent.tfstate"
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}

provider "azurerm" {
  features {}
}
