variable "env" {
  type = string
}

variable "location"{
  type = string
  default = "South Central US"
}

variable "appServicePlanTier" {
  type = string
  default = "Free"
}

variable "appServicePlanSize" {
  type = string
  default = "F1"
}

variable "containerRegistry" {
  type = string
  sensitive = true
}

variable "containerRegistryUser" {
  type = string
  sensitive = true
}

variable "containerRegistryPassword" {
  type = string
  sensitive = true
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
    tier = "${ var.appServicePlanTier }"
    size = "${ var.appServicePlanSize }"
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
  
  app_settings = {
    "DOCKER_REGISTRY_SERVER_URL" = "${ var.containerRegistry }"
    "DOCKER_REGISTRY_SERVER_USERNAME" = "${ var.containerRegistryUser }"
    "DOCKER_REGISTRY_SERVER_PASSWORD" = "${ var.containerRegistryPassword }"
  }


}

output "app-principal-id" {
  value       = azurerm_app_service.simple-area-calculator-backend-app-service.identity.0.principal_id
  sensitive   = true
  depends_on  = [azurerm_app_service.simple-area-calculator-backend-app-service]
}