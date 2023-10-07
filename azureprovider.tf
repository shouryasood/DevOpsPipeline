terraform {
  backend "azurerm" {
    resource_group_name  = "pipelineResGrp"
    storage_account_name = "my1str2ac"
    container_name       = "mycontainer"
    key                  = "terraform.tfstate"
  }
}
provider "azurerm" {
  features {}
}
