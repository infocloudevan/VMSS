locals {
  resource_group_name   = "${var.project_code}-${var.environment_code}"
  virtual_network_name  = "${var.project_code}-${var.environment_code}"
  load_balancer_name    = "${var.project_code}-${var.environment_code}-agents"
  managed_identity_name = "${var.project_code}-${var.environment_code}-agents"
}

data "azurerm_resource_group" "rg" {
  name = local.resource_group_name
}

data "azurerm_client_config" "current" {}


data "azurerm_lb" "default" {
  name                = local.load_balancer_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_subnet" "agents" {
  name                 = "agent-subnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = local.virtual_network_name
}

data "azurerm_user_assigned_identity" "default" {
  name                = local.managed_identity_name
  resource_group_name = data.azurerm_resource_group.rg.name
}
