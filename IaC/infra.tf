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

resource "azurerm_app_service_plan" "simple-area-calculator-backend-app-service-plann" {
  name                = "simple-area-calculator-backend-app-service-plann${ var.env != "production" ? "-${ var.env }" : "" }"
  location            = "${ var.location }"
  resource_group_name = "simple-area-calulator-backend-rg"
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
  resource_group_name = "simple-area-calulator-backend-rg"
  app_service_plan_id = azurerm_app_service_plan.simple-area-calculator-backend-app-service-plann.id

  identity {
    type = "SystemAssigned"
  }
}

output "app-principal-id" {
  value       = azurerm_app_service.simple-area-calculator-backend-app-service.identity.0.principal_id
  sensitive   = true
  depends_on  = [azurerm_app_service.simple-area-calculator-backend-app-service]
}
