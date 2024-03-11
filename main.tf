# Configure the Terraform runtime requirements.
terraform {
  required_version = ">= 1.1.0"

  required_providers {
    # Azure Resource Manager provider and version
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.95.0"
    }

  }
}

# Define providers and their config params
provider "azurerm" {
  # Leave the features block empty to accept all defaults
  features {}
}


variable "labelPrefix" {
  type        = string
  description = "Your college username. This will form the beginning of various resource names."
}

variable "region" {
  default = "westus3"
  type    = string
}

#resource group
resource "azurerm_resource_group" "rg" {
  name     = "${var.labelPrefix}-H09-RG"
  location = var.region
}


resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = "${var.labelPrefix}-cluster"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "akscluster"
  


  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2s"

  }

  identity {
    type = "SystemAssigned"
  }


}

output "kube_config" {
  value = azurerm_kubernetes_cluster.aks_cluster.kube_config_raw

  sensitive = true
}