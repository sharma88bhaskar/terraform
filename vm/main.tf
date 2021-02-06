provider "azurerm" {
  features {}
  subscription_id = "070cc18b-23e9-40a9-9052-648282af77e7"
  
}

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  resource_group_name             =  "azbsresourcegroup"
  location                        = "eastus2"

  ip_configuration {
    name                          = "default"
    subnet_id                     = "/subscriptions/070cc18b-23e9-40a9-9052-648282af77e7/resourceGroups/azbsresourcegroup/providers/Microsoft.Network/virtualNetworks/azbsresourcegroup-vnet/subnets/default"
    private_ip_address_allocation = "Dynamic"
  }
}


resource "azurerm_windows_virtual_machine" "main" {
  name                            = "${var.prefix}-vm"
  resource_group_name             =  "azbsresourcegroup"
  location                        = "eastus2"
  size                            = "Standard_F2"
  admin_username                  = "vmadmin"
  admin_password                  = "nhico@bat1119"
  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}

resource "azurerm_virtual_machine_extension" "domjoin" {
name = "domjoin"
virtual_machine_id = azurerm_windows_virtual_machine.main.id
publisher = "Microsoft.Compute"
type = "JsonADDomainExtension"
type_handler_version = "1.3"
settings = <<SETTINGS
{
		"Name": "azuredomain.net",
		"User": "vmadmin@azuredomain.net",
		"OUPath": "",
		"Restart": "true",
		"Options": "3"
}
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
{
  "Password": "nhico@bat1119"
}
PROTECTED_SETTINGS
}
