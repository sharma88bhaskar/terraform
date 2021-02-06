provider "azurerm" {
  features {}
  subscription_id = "170e1be3-dce1-42e3-b760-fa76a4b8fd1e"
}

resource "azurerm_resource_group" "example" {
  name     = "azure-functions-python-rg"
  location = var.location
}

resource "azurerm_virtual_network" "example" {
  name                = "${var.prefix}-network"
  resource_group_name = "${azurerm_resource_group.example.name}"
  location            = "${azurerm_resource_group.example.location}"
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "example" {
  name                 = "internal"
  virtual_network_name = "${azurerm_virtual_network.example.name}"
  resource_group_name  = "${azurerm_resource_group.example.name}"
  address_prefixes     = ["10.0.1.0/24"]
  service_endpoints    = ["Microsoft.Storage"]
  delegation {
    name = "example-delegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
}
}

resource "azurerm_storage_account" "example" {
  name                     = var.storageaccount
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

}

resource "azurerm_storage_account_network_rules" "example" {
  resource_group_name  = azurerm_resource_group.example.name
  storage_account_name = azurerm_storage_account.example.name

  default_action             = "Deny"
  virtual_network_subnet_ids = [azurerm_subnet.example.id]
}


resource "azurerm_app_service_plan" "example" {
  name                = "azure-functions-python-service-plan"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "example"{                                  
   name                = "${var.prefix}-webapp"                                  
   location            = azurerm_resource_group.example.location   
   resource_group_name = azurerm_resource_group.example.name       
   app_service_plan_id = azurerm_app_service_plan.example.id         
                                                                            
   site_config {                                                            
     linux_fx_version = "PYTHON|3.6"                                        
   }                                                                                                                                              
 }  

resource "azurerm_function_app" "example" {
  name                       = "python-test-functions"
  location                   = azurerm_resource_group.example.location
  resource_group_name        = azurerm_resource_group.example.name
  app_service_plan_id        = azurerm_app_service_plan.example.id
  storage_account_name       = azurerm_storage_account.example.name
  storage_account_access_key = azurerm_storage_account.example.primary_access_key
  os_type                    = "linux"
  version                    = "~3"
}

resource "azurerm_app_service_virtual_network_swift_connection" "example" {
  app_service_id = azurerm_app_service.example.id
  subnet_id      = azurerm_subnet.example.id
}