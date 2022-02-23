terraform {
  backend "azurerm" {
  container_name       = "terraform"
  key                  = "agent.tfstate"
  }
}