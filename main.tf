provider "azurerm" {
  features {}
  subscription_id = "72eb7803-e874-44cb-b6d9-33f2fa3eb88c"
}

resource "azurerm_resource_group" "main" {
  name     = "vpoutotRG"
  location = "francecentral"
}

resource "azurerm_log_analytics_workspace" "logs" {
  name                = "vpoutot-logs"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_group" "fastapi" {
  name                = "fastapiloan"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  os_type             = "Linux"
  restart_policy      = "OnFailure"
  dns_name_label      = "fastapiloan-${azurerm_resource_group.main.location}" 
  ip_address_type     = "Public"

  container {
    name   = "fastapiloan"
    image  = "vpoutotregistry.azurecr.io/fastapiloan:latest"
    cpu    = "1"
    memory = "1.5"

    environment_variables = {
      SECRET_KEY                   = var.secret_key
      ACCESS_TOKEN_EXPIRE_MINUTES  = var.access_token_expire_minutes
      DB_SERVER                    = var.db_server
      DB_NAME                      = var.db_name_api
      DB_USER                      = var.db_user
      DB_PASSWORD                  = var.db_password
    }

    ports {
      port     = 80
      protocol = "TCP"
    }
  }

  image_registry_credential {
    server   = "vpoutotregistry.azurecr.io"
    username = var.acr_username
    password = var.acr_password
  }

  diagnostics {
    log_analytics {
      workspace_id = azurerm_log_analytics_workspace.logs.workspace_id
      workspace_key = azurerm_log_analytics_workspace.logs.primary_shared_key
    }
  }
}

resource "azurerm_container_group" "django" {
  name                = "djangoloan"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  os_type             = "Linux"
  restart_policy      = "OnFailure"
  dns_name_label      = "djangoloan-${azurerm_resource_group.main.location}"  # Ajout du DNS
  ip_address_type     = "Public"
  
  container {
    name   = "djangoloan"
    image  = "vpoutotregistry.azurecr.io/djangoloan:v2"
    cpu    = "1"
    memory = "1.5"

    environment_variables = {
      API_BASE_URL                = "http://${azurerm_container_group.fastapi.dns_name_label}.francecentral.azurecontainer.io"
      DJANGO_SECRET_KEY           = var.django_secret_key
      EMAIL_HOST_PASSWORD1        = var.email_host_password1
      EMAIL_HOST_PASSWORD2        = var.email_host_password2
      EMAIL_HOST_PASSWORD3        = var.email_host_password3
      EMAIL_HOST_PASSWORD4        = var.email_host_password4
      DEBUG                       = var.debug
      DB_SERVER                   = var.db_server
      DB_NAME                     = var.db_name_django
      DB_USER                     = var.db_user
      DB_PASSWORD                 = var.db_password
    }

    ports {
      port     = 80
      protocol = "TCP"
    }
  }

  image_registry_credential {
    server   = "vpoutotregistry.azurecr.io"
    username = var.acr_username
    password = var.acr_password
  }

  diagnostics {
    log_analytics {
      workspace_id = azurerm_log_analytics_workspace.logs.workspace_id
      workspace_key = azurerm_log_analytics_workspace.logs.primary_shared_key
    }
  }
}

variable "secret_key" {}
variable "access_token_expire_minutes" {}
variable "db_server" {}
variable "db_name_api" {}
variable "db_name_django" {}
variable "db_user" {}
variable "db_password" {}
variable "acr_username" {}
variable "acr_password" {}
variable "django_secret_key" {}
variable "email_host_password1" {}
variable "email_host_password2" {}
variable "email_host_password3" {}
variable "email_host_password4" {}
variable "debug" {}
variable "api_base_url" {}

output "fastapi_ip" {
  value = azurerm_container_group.fastapi.ip_address
}

output "django_ip" {
  value = azurerm_container_group.django.ip_address
}
