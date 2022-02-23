variable "project_code" {
  default = "devops"
}

variable "environment_code" {
  default = "selfagent"
}

variable "location" {
  default = "eastus"
}

variable "network_cidr" {
  default = "10.0.0.0/16"
}

variable "agents_subnet_cidr" {
  default = "10.0.0.0/24"
}