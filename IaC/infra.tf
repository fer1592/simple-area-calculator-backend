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
  backend "azurerm" {}

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

resource "time_sleep" "wait_15_seconds_after_app_service_plann" {
  depends_on = [azurerm_app_service_plan.simple-area-calculator-backend-app-service-plann]
  create_duration = "15s"
}

resource "azurerm_app_service" "simple-area-calculator-backend-app-service" {
  name                = "simple-area-calculator-backend-app-service${ var.env != "production" ? "-${ var.env }" : "" }"
  location            = "${ var.location }"
  resource_group_name = "simple-area-calulator-backend-rg"
  app_service_plan_id = azurerm_app_service_plan.simple-area-calculator-backend-app-service-plann.id
  depends_on = [time_sleep.wait_15_seconds_after_app_service_plann]

  identity {
    type = "SystemAssigned"
  }

  dynamic "site_config" {
    for_each = var.appServicePlanTier == "Free" ? [] : [1]
    content {
      always_on = true
    }
  }

  app_settings = {
    "DOCKER_REGISTRY_SERVER_URL" = "${ var.containerRegistry }"
    "DOCKER_REGISTRY_SERVER_USERNAME" = "${ var.containerRegistryUser }"
    "DOCKER_REGISTRY_SERVER_PASSWORD" = "${ var.containerRegistryPassword }"
  }
}

resource "time_sleep" "wait_15_seconds_after_app_service" {
  depends_on = [azurerm_app_service.simple-area-calculator-backend-app-service]
  create_duration = "15s"
}

resource "azurerm_app_service_slot" "simple-area-calculator-backend-app-service-slot-staging" {
  name                = "simple-area-calculator-backend-app-service-slot-staging"
  app_service_name    = azurerm_app_service.simple-area-calculator-backend-app-service.name
  location            = "${ var.location }"
  resource_group_name = "simple-area-calulator-backend-rg"
  app_service_plan_id = azurerm_app_service_plan.simple-area-calculator-backend-app-service-plann.id
  count = "${ var.env == "production" ? 1 : 0}"
  depends_on = [time_sleep.wait_15_seconds_after_app_service]
  
  site_config {
    always_on = true
  }

  app_settings = {
    "DOCKER_REGISTRY_SERVER_URL" = "${ var.containerRegistry }"
    "DOCKER_REGISTRY_SERVER_USERNAME" = "${ var.containerRegistryUser }"
    "DOCKER_REGISTRY_SERVER_PASSWORD" = "${ var.containerRegistryPassword }"
  }
}