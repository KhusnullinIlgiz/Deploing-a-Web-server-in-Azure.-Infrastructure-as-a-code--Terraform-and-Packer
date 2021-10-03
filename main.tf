provider "azurerm" {
  features {}
}
# Creating resource group
resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-rg"
  location = var.location
  tags = {
    environment = var.environment
  }
}

# Creating virtual network for VM
resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = var.virtual_network_addr_space
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags = {
    environment = var.environment
  }
}

# Creating subnet for VM
resource "azurerm_subnet" "main" {
  name                 = "${var.prefix}-sub"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = var.subnet_addr_space
  
}

#Security group
resource "azurerm_network_security_group" "main"{
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

#Deny all traffic from Internet
  security_rule {
    name                       = "denyAllV-NET"
    priority                   = 500
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80 - 843"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

#Allow inside traffic inside V-NET
  security_rule {
    name                       = "allowAllV-NET-inside"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.virtual_network_addr_space[0]
    destination_address_prefix = var.virtual_network_addr_space[0]
  }

  #Allow outside traffic V-NET
  security_rule {
    name                       = "allowAllV-NET-outside"
    priority                   = 101
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.virtual_network_addr_space[0]
    destination_address_prefix = var.virtual_network_addr_space[0]
  }

  #Allow HTTP load balancer inside traffic V-NET
  security_rule {
    name                       = "allowAllV-NET-lb"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = var.virtual_network_addr_space[0]
    destination_address_prefix = var.virtual_network_addr_space[0]
  }


  tags = {
    environment = var.environment
  }
} 


# Creating network interface for VM
resource "azurerm_network_interface" "main" {
  count               = var.num_vms
  name                = "${var.prefix}-${count.index}-nic"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  ip_configuration {
    primary                       = true
    name                          = "${var.prefix}-internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
  }
  tags = {
    environment = var.environment
  }
}

# association between a Network Interface and a Network Security Group
resource "azurerm_network_interface_security_group_association" "main" {
  count                     = var.num_vms
  network_interface_id      = element(azurerm_network_interface.main.*.id, count.index)
  network_security_group_id = azurerm_network_security_group.main.id

}

# Creating public staatic IP for load balancer
resource "azurerm_public_ip" "main" {
  name                = "${var.prefix}-pub-ip"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"

  tags = {
    environment = var.environment
  }
}

# Creating load balancer
resource "azurerm_lb" "main" {
  name                = "${var.prefix}-load-balancer"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  frontend_ip_configuration {
    name                 = "${var.prefix}-PublicIP"
    public_ip_address_id = azurerm_public_ip.main.id
  }
  tags = {
    environment = var.environment
  }
}

# Load Balancer Backend Address Pool
resource "azurerm_lb_backend_address_pool" "main" {
  loadbalancer_id = azurerm_lb.main.id
  name            = "${var.prefix}-BackEndAddressPool"


}


# LoadBalancer Probe Resource
resource "azurerm_lb_probe" "main" {
  resource_group_name = azurerm_resource_group.main.name
  loadbalancer_id     = azurerm_lb.main.id
  name                = "${var.prefix}-lbprobe"
  port                = 8080

}

# load balancer#s rule for VM
resource "azurerm_lb_rule" "main" {
  resource_group_name            = azurerm_resource_group.main.name
  loadbalancer_id                = azurerm_lb.main.id
  name                           = "${var.prefix}-lbrule"
  protocol                       = "TCP"
  frontend_port                  = 80
  backend_port                   = 8080
  frontend_ip_configuration_name = "${var.prefix}-PublicIP"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.main.id
  probe_id                       = azurerm_lb_probe.main.id

}

# association between a Network Interface and a Load Balancer's Backend Address Pool
resource "azurerm_network_interface_backend_address_pool_association" "main" {
  count                   = var.num_vms
  network_interface_id    = azurerm_network_interface.main[count.index].id
  ip_configuration_name   = "${var.prefix}-internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id

}

# adjusting availability 
resource "azurerm_availability_set" "main" {
  name                        = "${var.prefix}-aset"
  location                    = azurerm_resource_group.main.location
  resource_group_name         = azurerm_resource_group.main.name
  platform_fault_domain_count = 2

  tags = {
    environment = var.environment
  }
}

# Reference to the Packer image
data "azurerm_image" "myPackerImage" {
  name                = "myPackerImage"
  resource_group_name = var.image_rs_group
}

#Creating VM's from packer image
resource "azurerm_linux_virtual_machine" "main" {
  count                           = var.num_vms
  name                            = "${var.prefix}-vm-${count.index}"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  size                            = var.vm_size
  admin_username                  = var.username
  admin_password                  = var.password
  disable_password_authentication = false

  network_interface_ids = [element(azurerm_network_interface.main.*.id, count.index)]
  availability_set_id   = azurerm_availability_set.main.id

  source_image_id = data.azurerm_image.myPackerImage.id

  os_disk {
    name                 = "${var.prefix}-vm-${count.index}-disk-storage"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  tags = {
    environment  = var.environment
  }
}

#virtual disks VM's
resource "azurerm_managed_disk" "main" {
  count                = var.num_vms
  name                 = "${var.prefix}-data-disk-${count.index}"
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 1
   tags = {
    environment = var.environment
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "main" {
  count              = var.num_vms
  managed_disk_id    = azurerm_managed_disk.main.*.id[count.index]
  virtual_machine_id = azurerm_linux_virtual_machine.main.*.id[count.index]
  lun                = "0"
  caching            = "ReadWrite"

}


# Static IP Address Output 

output "static_ip" {
  value       = azurerm_public_ip.main.ip_address
  description = "Static IP Address"
}
