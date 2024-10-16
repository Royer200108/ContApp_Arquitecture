resource "azurerm_linux_function_app" "function_app_ca" {
    name                = "function-ca-${var.project}-${var.enviroment}"
    location            = var.location
    resource_group_name = azurerm_resource_group.rg.name
    service_plan_id            = azurerm_service_plan.app_service_plan_ca.id

    storage_account_name       = azurerm_storage_account.storage_account.name
    storage_account_access_key = azurerm_storage_account.storage_account.primary_connection_string
    //version = ~3

    
    site_config {
        //linux_fx_version          = "DOCKER|mcr.microsoft.com/azure-functions/dotnet:4-appservice-quickstart"  # Usas una imagen Docker válida
        always_on                 = true
        vnet_route_all_enabled     = true

        ip_restriction {
        name                    = "default-deny"
        ip_address              = "0.0.0.0/0"
        action                  = "Deny"
        priority                = 200
        }
    }
    
    app_settings = {
        "AzureWebJobsStorage"             = azurerm_storage_account.storage_account.primary_connection_string
        "AzureWebJobsDashboard"           = azurerm_storage_account.storage_account.primary_connection_string
        "WEBSITE_VNET_ROUTE_ALL"          = "1"
        "QueueStorageConnectionString"    = azurerm_storage_account.storage_account.primary_connection_string
        "QueueName"                       = azurerm_storage_queue.storage_queue.name
        "DOCKER_REGISTRY_SERVER_URL"      = "https://${azurerm_container_registry.acr.login_server}"
        "DOCKER_REGISTRY_SERVER_USERNAME" = azurerm_container_registry.acr.admin_username
        "DOCKER_REGISTRY_SERVER_PASSWORD" = azurerm_container_registry.acr.admin_password

        "DOCKER_CUSTOM_IMAGE_NAME"        = "mcr.microsoft.com/azure-functions/dotnet:4-appservice-quickstart"  # Definir la imagen aquí
    }

    identity {
        type = "SystemAssigned"  # Usas identidad administrada
    }

    tags = var.tags

    depends_on = [
        azurerm_service_plan.app_service_plan_ca,
        azurerm_subnet.subnetfunction,
        azurerm_container_registry.acr
    ]
}

resource "azurerm_private_endpoint" "function_private_endpoint"{

    name = "function-private-endpoint-${var.project}-${var.enviroment}"
    resource_group_name = azurerm_resource_group.rg.name
    location = var.location
    subnet_id = azurerm_subnet.subnetfunction.id

    private_service_connection {
        name = "function-private-ec-${var.project}-${var.enviroment}"
        private_connection_resource_id = azurerm_linux_function_app.function_app_ca.id
        subresource_names = ["sites"]
        is_manual_connection = false
    }

    tags = var.tags

}

resource "azurerm_private_dns_zone" "function_private_dns_zone"{
    name= "private.function-${var.project}-${var.enviroment}.azurewebsites.net"
    resource_group_name = azurerm_resource_group.rg.name

    tags = var.tags

}

resource "azurerm_private_dns_a_record" "function_private_dns_a_record"{

    name = "function-record-${var.project}-${var.enviroment}"
    zone_name = azurerm_private_dns_zone.function_private_dns_zone.name
    resource_group_name = azurerm_resource_group.rg.name
    ttl = 300
    records = [azurerm_private_endpoint.function_private_endpoint.private_service_connection[0].private_ip_address]

}

resource "azurerm_private_dns_zone_virtual_network_link" "function_vnet_link"{
    name = "functionlink-${var.project}-${var.enviroment}"
    resource_group_name = azurerm_resource_group.rg.name
    private_dns_zone_name = azurerm_private_dns_zone.function_private_dns_zone.name
    virtual_network_id = azurerm_virtual_network.vnet.id
}