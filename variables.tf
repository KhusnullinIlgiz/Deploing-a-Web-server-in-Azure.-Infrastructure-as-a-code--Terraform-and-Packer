variable "prefix" {
  description = "The prefix which should be used for all resources"
  default = "udacity-project1"
}

variable "image_rs_group" {
  description = "The prefix which should be used for all resources"
  default = "packer-rg"
}

variable "location" {
  description = "The Azure Region in which all resources should be created"
  default = "Germany West Central"
}

variable "password"{
  description = "VM's user password"
  default = "Passw0rd"
}

variable "username"{
description = "VM's user name"
default = "adminuser"
}

variable "virtual_network_addr_space"{
  description = "Address space virtual network's"
  default = ["10.0.0.0/16"]
}

variable "subnet_addr_space"{
  description = "Address space virtual network's"
  default = ["10.0.0.0/24"]
}

variable "num_vms"{
  description = "by adjusting this variable -> number of VM's will be regulated"
  default = 3
  type = number
}

variable "environment"{
  description = "Tag's environment"
  default = "udacity-project1"
}

variable "vm_size"{
  description = "VM's size"
  default = "Standard_D2s_v3"
}