provider "azurerm" {

    features {}
    subscription_id="09911d4d-661e-4e37-ac0d-163e1bd882f0"
    
}

resource "azurerm_resource_group" "rg" {
    
    name = "rg-${var.project}-${var.enviroment}"
    location = var.location

    tags = var.tags

}