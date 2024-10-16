//Creating the Container registry for the WebApp
resource "azurerm_container_registry" "acr" {

    name                = "acr${var.project}${var.enviroment}"
    resource_group_name = azurerm_resource_group.rg.name
    location            = var.location
    sku                 = "Basic"
    
    admin_enabled       = true

    tags = var.tags
}


//Configuration for the BackOffice webapp------------------------------------------
//Create the App Service Plan resource for the BackOffice App
resource "azurerm_service_plan" "app_service_plan_bf" {

    name = "asp-bf-${var.project}-${var.enviroment}"
    location = var.location
    resource_group_name = azurerm_resource_group.rg.name
    
    os_type = "Linux"

    sku_name = "B1"

    tags = var.tags

}


//Creating the App Service for the UI BackOffice webapp
resource "azurerm_linux_web_app" "webapp_bf_ui" {
    name                = "ui-bf-${var.project}-${var.enviroment}"
    location            = var.location
    resource_group_name = azurerm_resource_group.rg.name
    service_plan_id     = azurerm_service_plan.app_service_plan_bf.id

    site_config {
        ### NEW Docker credential definition --------------------------------
        application_stack { 
            docker_image_name        = "bf-ui:latest"
            docker_registry_url      = "https://${azurerm_container_registry.acr.login_server}"
            docker_registry_username = azurerm_container_registry.acr.admin_username
            docker_registry_password = azurerm_container_registry.acr.admin_password
        }
        ### ------------------------------------------------------------------

        always_on        = "true"
        vnet_route_all_enabled = true
    }

    app_settings = {
        vnet_route_all_enabled = "1"
    }
    
    //The dependencies for this webapp
    depends_on = [
        azurerm_service_plan.app_service_plan_bf,
        azurerm_container_registry.acr,
        azurerm_subnet.backofficesubnet
    ]

    tags = var.tags
}

//Configuring the conection with outbound (it need access to the VNets too)
resource "azurerm_app_service_virtual_network_swift_connection" "webapp_bf_ui_vnet_integration" {
    app_service_id    = azurerm_linux_web_app.webapp_bf_ui.id
    subnet_id         = azurerm_subnet.backofficesubnet.id
    depends_on = [
        azurerm_linux_web_app.webapp_bf_ui
    ]
}

//Creating the App Service for the API BackOffice webapp
resource "azurerm_linux_web_app" "webapp_bf_api" {
    name = "api-bf-${var.project}-${var.enviroment}"
    location            = var.location
    resource_group_name = azurerm_resource_group.rg.name
    service_plan_id = azurerm_service_plan.app_service_plan_bf.id

    //Configuring the specifications to activate Docker deployments
    site_config {
        ### NEW Docker credential definition --------------------------------
        application_stack { 
            docker_image_name        = "bf-api:latest"
            docker_registry_url      = "https://${azurerm_container_registry.acr.login_server}"
            docker_registry_username = azurerm_container_registry.acr.admin_username
            docker_registry_password = azurerm_container_registry.acr.admin_password
        }
        ### ------------------------------------------------------------------

        always_on        = "true"
        vnet_route_all_enabled = true
    }

    app_settings = {
        vnet_route_all_enabled = "1"
    }

    //The dependencies for this webapp
    depends_on = [
        azurerm_service_plan.app_service_plan_bf,
        azurerm_container_registry.acr,
        azurerm_subnet.backofficesubnet
    ]

    tags = var.tags

}

//Configuring the conection with outbound (it need access to the VNets too)
resource "azurerm_app_service_virtual_network_swift_connection" "webapp_bf_api_vnet_integration" {
    app_service_id    = azurerm_linux_web_app.webapp_bf_api.id
    subnet_id         = azurerm_subnet.backofficesubnet.id
    depends_on = [
        azurerm_linux_web_app.webapp_bf_api
    ]
}



//Configuration for the ContAPP webapp------------------------------
//Create the App Service Plan resource for the CountApp App
resource "azurerm_service_plan" "app_service_plan_ca" {

    name = "asp-ca-${var.project}-${var.enviroment}"
    location = var.location
    resource_group_name = azurerm_resource_group.rg.name
    os_type = "Linux"

    sku_name = "S1"

    tags = var.tags

}

//Creating the App Service for the UI ContApp webapp
resource "azurerm_linux_web_app" "webapp_ca_ui" {
    name = "ui-ca-${var.project}-${var.enviroment}"
    location            = var.location
    resource_group_name = azurerm_resource_group.rg.name
    service_plan_id = azurerm_service_plan.app_service_plan_ca.id

    //Configuring the specifications to activate Docker deployments
    site_config {
        ### NEW Docker credential definition --------------------------------
        application_stack { 
            docker_image_name        = "ca-ui:latest"
            docker_registry_url      = "https://${azurerm_container_registry.acr.login_server}"
            docker_registry_username = azurerm_container_registry.acr.admin_username
            docker_registry_password = azurerm_container_registry.acr.admin_password
        }
        ### ------------------------------------------------------------------

        always_on        = "true"
        vnet_route_all_enabled = true
    }

    app_settings = {
        vnet_route_all_enabled = "1"
    }    

    //The dependencies for this webapp
    depends_on = [
        azurerm_service_plan.app_service_plan_ca,
        azurerm_container_registry.acr,
        azurerm_subnet.contappsubnet
    ]

    tags = var.tags

}

//Configuring the conection with outbound (it need access to the VNets too)
resource "azurerm_app_service_virtual_network_swift_connection" "webapp_ca_ui_vnet_integration" {
    app_service_id    = azurerm_linux_web_app.webapp_ca_ui.id
    subnet_id         = azurerm_subnet.contappsubnet.id
    depends_on = [
        azurerm_linux_web_app.webapp_ca_ui
    ]
}


//Creating the App Service for the API ContApp webapp
resource "azurerm_linux_web_app" "webapp_ca_api" {
    name = "api-ca-${var.project}-${var.enviroment}"
    location            = var.location
    resource_group_name = azurerm_resource_group.rg.name
    service_plan_id = azurerm_service_plan.app_service_plan_ca.id

    //Configuring the specifications to activate Docker deployments
    site_config {
        ### NEW Docker credential definition --------------------------------
        application_stack { 
            docker_image_name        = "ca-api:latest"
            docker_registry_url      = "https://${azurerm_container_registry.acr.login_server}"
            docker_registry_username = azurerm_container_registry.acr.admin_username
            docker_registry_password = azurerm_container_registry.acr.admin_password
        }
        ### ------------------------------------------------------------------

        always_on        = "true"
        vnet_route_all_enabled = true
    }

    app_settings = {
        vnet_route_all_enabled = "1"
    }

    //The dependencies for this webapp
    depends_on = [
        azurerm_service_plan.app_service_plan_ca,
        azurerm_container_registry.acr,
        azurerm_subnet.contappsubnet
    ]

    tags = var.tags

}

//Configuring the conection with outbound (it need access to the VNets too)
resource "azurerm_app_service_virtual_network_swift_connection" "webapp_ca_api_vnet_integration" {
    app_service_id    = azurerm_linux_web_app.webapp_ca_api.id
    subnet_id         = azurerm_subnet.contappsubnet.id
    depends_on = [
        azurerm_linux_web_app.webapp_ca_api
    ]
}