terraform {
  backend "azurerm" {
  container_name       = "terraform"
  key                  = "network.tfstate"
  }
}