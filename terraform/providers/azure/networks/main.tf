# Networks

variable "rg_name" {}
variable "region" {}
variable "cluster_name" {}
variable "cidr" { default = "10.2.0.0/16" }


 resource "azurerm_virtual_network" "uhsky-researchlab" {
  name                = "${var.cluster_name}-vnet"
  address_space       = ["${var.cidr}"]
  location            = "${var.region}"
  resource_group_name = "${var.rg_name}"
}

resource "azurerm_subnet" "uhsky-researchlab" {
  name                  = "${var.cluster_name}-subnet"
  resource_group_name   = "${var.rg_name}"
  virtual_network_name  = "${azurerm_virtual_network.uhsky-researchlab.name}"
  address_prefix        = "${var.cidr}"
  depends_on            = ["azurerm_virtual_network.uhsky-researchlab"]
}
