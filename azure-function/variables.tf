variable "location" {
  description = "The Azure Region in which all resources in this example should be provisioned"
  default = "East US 2"
}

variable "storageaccount" {
  description = "Name of the storage account"
  default = "azbsfunctionstorage"
}

variable "prefix" {
  description = "resource group prefix"
default="azbsdev"
}