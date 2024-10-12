//Configuring the Storage Account
resource "azurerm_storage_account" "storage_account" {
    //this name is UNIC in the world
    //This name cant contain the the next characters (space, -, _, special characters, upper case)    
    name = "storage${var.project}${var.enviroment}"
    resource_group_name = azurerm_resource_group.rg.name
    location = var.location
    account_tier = "Standard"
    account_replication_type = "LRS"

    tags = var.tags

}

//Creating the Queue Storage and the Blob Storage 
//For a KnowLedge DataBase
resource "azurerm_storage_container" "blob_dbk_container" {
    name = "dbknowledge"                                                    
    storage_account_name = azurerm_storage_account.storage_account.name
    container_access_type = "private"
}
//For a Vector Data Base
resource "azurerm_storage_container" "blob_dbv_container" {
    name = "dbvector"                                                    
    storage_account_name = azurerm_storage_account.storage_account.name
    container_access_type = "private"
}
    //This Queue Storage is for the Vector DataBase
resource "azurerm_storage_queue" "storage_queue" {
    name = "vectordb-calibration-request"
    storage_account_name = azurerm_storage_account.storage_account.name
}

//Configuring the Private EndPoints-----------------------------
//Configuring the private endpoint for the Blob Storage
resource "azurerm_private_endpoint" "blob_private_endpoint" {
    name = "blob-private-endpoint-${var.project}-${var.enviroment}"
    resource_group_name = azurerm_resource_group.rg.name
    location = var.location
    subnet_id = azurerm_subnet.subnetstorage.id

    private_service_connection {
        name = "storage-private-${var.project}-${var.enviroment}"
        private_connection_resource_id = azurerm_storage_account.storage_account.id
        subresource_names = ["blob"]
        is_manual_connection = false
    }

    tags = var.tags
}

//Configuring the private endpoint for the Queue Storage
resource "azurerm_private_endpoint" "queue_private_endpoint" {
    name = "queue-private-endpoint-${var.project}-${var.enviroment}"
    resource_group_name = azurerm_resource_group.rg.name
    location = var.location
    subnet_id = azurerm_subnet.subnetstorage.id

    private_service_connection {
        name = "storage-private-${var.project}-${var.enviroment}"
        private_connection_resource_id = azurerm_storage_account.storage_account.id
        subresource_names = ["queue"]
        is_manual_connection = false
    }

    tags = var.tags
}


//Configuring the DNS Zone
resource "azurerm_private_dns_zone" "sa_private_dns_zone" {
    //this name is the private DNS for access this server
    name = "privatelink.storage.core.windows.net"
    resource_group_name = azurerm_resource_group.rg.name

    tags = var.tags

}


//Configuring the DNS Records
resource "azurerm_private_dns_a_record" "sa_private_dns_a_record" {
    
    name = "storage-record-${var.project}-${var.enviroment}"
    zone_name = azurerm_private_dns_zone.sa_private_dns_zone.name
    resource_group_name = azurerm_resource_group.rg.name
    ttl = 300
    records = [
        azurerm_private_endpoint.blob_private_endpoint.private_service_connection[0].private_ip_address,
        azurerm_private_endpoint.queue_private_endpoint.private_service_connection[0].private_ip_address
        ]
        //Asi se configura el record para que extraiga la ip del Private Endpoint
        //Recordar que el record va conectado al end point o interfaz que se ha confiurado
        

}

//Configuring the DNS Zone to be accesible from the entrey VNet 
resource "azurerm_private_dns_zone_virtual_network_link" "sa_vnet_link" {
    name = "sa-vnet-link-${var.project}-${var.enviroment}"                 
    resource_group_name = azurerm_resource_group.rg.name
    private_dns_zone_name = azurerm_private_dns_zone.sa_private_dns_zone.name
    virtual_network_id = azurerm_virtual_network.vnet.id
}

