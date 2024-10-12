//Creating the SQLServer resource (its not the sql db)
resource "azurerm_mssql_server" "sql_server" {      
    //This name is UNIC in the world 
    name = "sqlserv-${var.project}-${var.enviroment}"
    resource_group_name = azurerm_resource_group.rg.name
    location = var.location
    version = "12.0"
    administrator_login = "sqladmin"
    administrator_login_password = var.password

    tags = var.tags
}

//Creating the database
resource "azurerm_mssql_database" "sql_db" {
    
    name = "${var.project}.db"
    server_id = azurerm_mssql_server.sql_server.id
    sku_name = "S0"
    
    tags = var.tags

}

//Configuring the private EndPoints---------------------------
//Configuring the private endpoint for the SQLServer
resource "azurerm_private_endpoint" "sql_private_endpoint" {
    name = "sql-private-endpoint-${var.project}-${var.enviroment}"
    resource_group_name = azurerm_resource_group.rg.name
    location = var.location
    subnet_id = azurerm_subnet.subnetdb.id

    //Configuring the connection with the SQLServer
    private_service_connection {
        name = "sql-private-epconnect-${var.project}-${var.enviroment}"
        private_connection_resource_id = azurerm_mssql_server.sql_server.id
        subresource_names = ["sqlServer"]
        is_manual_connection = false                                        //
    }

    tags = var.tags
}

//Configuring the DNS Zone
resource "azurerm_private_dns_zone" "private_dns_zone" {
    //this name is the private DNS for access this server
    name = "private.dbserver.database.windows.net"
    resource_group_name = azurerm_resource_group.rg.name

    tags = var.tags

}

//Configuring the DNS Records
resource "azurerm_private_dns_a_record" "private_dns_a_record" {
    
    name = "sqlserver-record-${var.project}-${var.enviroment}"
    zone_name = azurerm_private_dns_zone.private_dns_zone.name
    resource_group_name = azurerm_resource_group.rg.name
    ttl = 300
    records = [
        azurerm_private_endpoint.sql_private_endpoint.private_service_connection[0].private_ip_address
    ]
        //Configuring the Record to extract the IP of the Private Endpoint
        //Remember: The Record will be connected at the End Point (Interface configurated)

}

//Configuring the DNS Zone to be accesible from the entrey VNet 
resource "azurerm_private_dns_zone_virtual_network_link" "vnet_link" {

    name = "vnet-link-${var.project}-${var.enviroment}"
    resource_group_name = azurerm_resource_group.rg.name
    private_dns_zone_name = azurerm_private_dns_zone.private_dns_zone.name
    virtual_network_id = azurerm_virtual_network.vnet.id

}

//Thi sets up the Firewall rule, so i can access the database from my Local PC
resource "azurerm_mssql_firewall_rule" "allow_my_ip" {
    name                = "allow-my-ip"
    server_id = azurerm_mssql_server.sql_server.id
    start_ip_address = "192.168.0.0"
    end_ip_address = "192.168.0.25"
}