// Provider used = AZURE 
// IaC Tool = Terraform

# Defining Resource Group
data "azurerm_resource_group" "az_rg" {
  name     = "pipelineResGrp"
}

# Defining Storage Account
data "azurerm_storage_account" "az_sa" {
  name                     = "my1str2ac"
  resource_group_name      = data.azurerm_resource_group.az_rg.name
}

# Defining Container in Storage Account
data "azurerm_storage_container" "az_sa_c" {
  name                  = "mycontainer"
  storage_account_name  = data.azurerm_storage_account.az_sa.name
}

# Defining Azure SQL Database
resource "azurerm_mssql_server" "az_sql_server" {
  name                         = "my-sql-server-my-sql-server"
  resource_group_name          = data.azurerm_resource_group.az_rg.name
  location                     = data.azurerm_resource_group.az_rg.location
  administrator_login          = "shouryasood"
  administrator_login_password = var.pwd
  version                      = "12.0"
}

resource "azurerm_mssql_database" "az_sql_db" {
  name                = "my-sql-db"
  server_id         = azurerm_mssql_server.az_sql_server.id
  collation           = "SQL_Latin1_General_CP1_CI_AS"
}

# Defining Azure Data Factory
resource "azurerm_data_factory" "az_data_factory" {
  name                = "my-data-factory"
  resource_group_name = data.azurerm_resource_group.az_rg.name
  location            = data.azurerm_resource_group.az_rg.location
}

# Defining Azure VM for Airflow
resource "azurerm_virtual_machine" "az_vm" {
  vm_size              = "Standard_DS2_v2"
  name                 = "my-airflow-vm"
  resource_group_name  = data.azurerm_resource_group.az_rg.name
  location             = data.azurerm_resource_group.az_rg.location
  network_interface_ids = [azurerm_network_interface.az_nic.id]
  # Define the OS image here if needed
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
}


# Defining Azure Virtual Network and Subnet
resource "azurerm_virtual_network" "azvitnet" {
  name                = "example-vnet"
  address_space       = ["10.0.0.0/16"]  # Define the VNet address range
  location            = data.azurerm_resource_group.az_rg.location 
  resource_group_name = data.azurerm_resource_group.az_rg.name  
}
resource "azurerm_subnet" "example" {
  name                 = "example-subnet"
  resource_group_name  = data.azurerm_resource_group.az_rg.name  
  virtual_network_name = azurerm_virtual_network.azvitnet.name  
  address_prefixes     = ["10.0.1.0/24"]  # Define the subnet address range
}

# Defining Azure Network Interface
resource "azurerm_network_interface" "az_nic" {
  name                = "my-network-interface"
  location            = data.azurerm_resource_group.az_rg.location
  resource_group_name = data.azurerm_resource_group.az_rg.name
  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.example.id  # Replace with the actual subnet ID
    private_ip_address_allocation = "Dynamic"  # You can use "Static" if needed
  }
}
