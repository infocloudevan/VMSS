locals {
  resource_group_name    = "${var.project_code}-${var.environment_code}"
  virtual_network_name   = "${var.project_code}-${var.environment_code}"
  network_security_group_name = "${var.project_code}-${var.environment_code}-agents"
  public_ip_name         = "${var.project_code}-${var.environment_code}-agents"
  load_balancer_name     = "${var.project_code}-${var.environment_code}-agents"
  managed_identity_name  = "${var.project_code}-${var.environment_code}-agents"
}

################################################################################
# Resource Group
################################################################################


resource "azurerm_resource_group" "rg" {
  name     = local.resource_group_name
  location = var.location
}

################################################################################
# Virtual Network
################################################################################

resource "azurerm_virtual_network" "default" {
  name                = local.virtual_network_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.location

  address_space = [var.network_cidr]

  #   tags = {
  #   app = ""
  #   env =""
  # }

}

# Subnet
# ------

resource "azurerm_subnet" "agents" {
  name                 = "agent-subnet"
  resource_group_name      = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.default.name

  address_prefixes            = [var.agents_subnet_cidr]

  /*service_endpoints = [
    "Microsoft.AzureActiveDirectory",
    "Microsoft.KeyVault",
    "Microsoft.Sql",
    "Microsoft.Storage",
  ]*/
}

# Network Security Group
# ----------------------

resource "azurerm_network_security_group" "agents" {
  name                = local.network_security_group_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.location

  security_rule {
    name                       = "rdp"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # tags = {
  #   app = ""
  #   env = ""
  # }
}

resource "azurerm_subnet_network_security_group_association" "agents" {
  subnet_id                 = azurerm_subnet.agents.id
  network_security_group_id = azurerm_network_security_group.agents.id
}

################################################################################
# Public IP
################################################################################

resource "azurerm_public_ip" "default" {
  name                = local.public_ip_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.location

  sku               = "Standard"
  allocation_method = "Static"

  # tags = {
  #   app = ""
  #   env = ""
  # }
}

################################################################################
# Load Balancer
################################################################################

resource "azurerm_lb" "default" {
  name                = local.load_balancer_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.location

  sku = "Standard"

  frontend_ip_configuration {
    name                 = "public"
    public_ip_address_id = azurerm_public_ip.default.id
  }

  # tags = {
  #   app = ""
  #   env = ""
  # }
}

################################################################################
# Managed Identity
################################################################################

resource "azurerm_user_assigned_identity" "default" {
  name                = local.managed_identity_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.location

  # tags = {
  #   app = ""
  #   env = ""
  # }
}
