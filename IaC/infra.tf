variable "env" {
  type = string
}

variable "location"{
  type = string
  default = "South Central US"
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "simple-area-calulator-rg" {
  name     = "simple-area-calulator-backend-rg${var.env != "production" ? "-${ var.env }" : ""}"
  location = "${ var.location }"
}

resource "azurerm_container_registry" "simple-area-calculator-backend-container-registry" {
  name                = "simpleAreaCalculatorBackendContainerRegistry${ var.env != "production" ? "${ var.env }" : "" }"
  resource_group_name = azurerm_resource_group.simple-area-calulator-rg.name
  location            = "${ var.location }"
  sku                 = "Basic"
  admin_enabled       = true
}

resource "time_sleep" "wait_10_seconds" {
  depends_on      = [azurerm_container_registry.simple-area-calculator-backend-container-registry]
  create_duration = "10s"
}

data "azurerm_container_registry" "simple-area-calculator-backend-container-registry" {
  name                = "simpleAreaCalculatorBackendContainerRegistry${ var.env != "production" ? "${ var.env }" : "" }"
  resource_group_name = azurerm_resource_group.simple-area-calulator-rg.name
  depends_on          = [time_sleep.wait_10_seconds]
}

output "container_registry_login_server" {
  value     = data.azurerm_container_registry.simple-area-calculator-backend-container-registry.login_server
  sensitive = true
}

output "container_registry_username" {
  value     = data.azurerm_container_registry.simple-area-calculator-backend-container-registry.admin_username
  sensitive = true
}

output "container_registry_password" {
  value     = data.azurerm_container_registry.simple-area-calculator-backend-container-registry.admin_password
  sensitive = true
}

resource "azurerm_app_service_plan" "simple-area-calculator-backend-app-service-plann" {
  name                = "simple-area-calculator-backend-app-service-plann${ var.env != "production" ? "-${ var.env }" : "" }"
  location            = "${ var.location }"
  resource_group_name = azurerm_resource_group.simple-area-calulator-rg.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Free"
    size = "F1"
  }
}

resource "azurerm_app_service" "simple-area-calculator-backend-app-service" {
  name                = "simple-area-calculator-backend-app-service${ var.env != "production" ? "-${ var.env }" : "" }"
  location            = "${ var.location }"
  resource_group_name = azurerm_resource_group.simple-area-calulator-rg.name
  app_service_plan_id = azurerm_app_service_plan.simple-area-calculator-backend-app-service-plann.id
}