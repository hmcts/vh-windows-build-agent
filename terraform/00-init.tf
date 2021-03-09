terraform {
  required_version = ">= 0.12"
  backend "azurerm" {
    container_name = "tfstate"
    key            = "infra/vh-build-agent.tfstate"
  }
}

provider "azurerm" {
  features {}
}
