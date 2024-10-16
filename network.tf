/*
Creating the VNet resource...
It will contains the configuration of the projects net
*/
resource "azurerm_virtual_network" "vnet" {

    name = "vnet-${var.project}-${var.enviroment}"
    resource_group_name = azurerm_resource_group.rg.name
    location = var.location
    address_space = ["10.0.0.0/16"]

    tags = var.tags

}

//The SubNets configuration--------------------------------

/*
Creating the SubNet fot the storage resources
*/
resource "azurerm_subnet" "subnetstorage" {

    name = "subnet-storage-${var.project}-${var.enviroment}"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes = ["10.0.1.0/24"]

}

/*
Creating the SubNet fot the database resource
*/
resource "azurerm_subnet" "subnetdb" {

    name = "subnet-db-${var.project}-${var.enviroment}"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes = ["10.0.2.0/24"]

}

/*
Creating the SubNet fot the webapp backoffice resource
*/
resource "azurerm_subnet" "backofficesubnet" {

    name = "subnet-backoffice-${var.project}-${var.enviroment}"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes = ["10.0.3.0/24"]

//Esto se agrega especificamente para trabajar con webapps
    //Se usan para especificar que todo IO-bound es para poder proveer el servicio web 
    delegation {
        name = "backoffice_delegation"
        service_delegation {
            name = "Microsoft.Web/serverFarms"
            actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
        }
    }
}

/*
Creating the SubNet fot the webapp backoffice resource
*/
resource "azurerm_subnet" "contappsubnet" {

    name = "subnet-contapp-${var.project}-${var.enviroment}"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes = ["10.0.4.0/24"]

    delegation {
        name = "contapp_delegation"
        service_delegation {
            name = "Microsoft.Web/serverFarms"
            actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
        }
    }
}

resource "azurerm_subnet" "subnetfunction" {

    name = "subnet-function-${var.project}-${var.enviroment}"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes = ["10.0.5.0/24"]

}