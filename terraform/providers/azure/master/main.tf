variable "instance_type" {}
variable "image" {}
variable "count" {}
variable "cluster_name" {}

variable "os_admin_user" {}
variable "os_adm_passwd" {}
variable "ssh_public_key_file" {}

variable "tag_environment" {}
variable "tag_activity" {}

variable "region" {}
variable "rg_name" {}

variable "subnet_id" {}
variable "master_sg_id" {}

variable "api-lb_bp-id" {}
variable "api_sg_id" {}

# Master nodes

resource "azurerm_availability_set" "master" {
  name                = "masterAvailabilitySet"
  location            = "${var.region}"
  resource_group_name = "${var.rg_name}"
  managed             = "true"

  tags {
    environment = "${var.tag_environment}",
    uninett_activity = "${var.tag_activity}"
  }
}

resource "azurerm_public_ip" "master" {
  name                         = "${var.cluster_name}-master-pip-${count.index}"
  location                     = "${var.region}"
  resource_group_name          = "${var.rg_name}"
  public_ip_address_allocation = "static"
  count                        = "${var.count}"

  tags {
    environment = "${var.tag_environment}",
    uninett_activity = "${var.tag_activity}"
  }
}

resource "azurerm_network_interface" "master" {
  name                      = "${var.cluster_name}-master-ni-${count.index}"
  location                  = "${var.region}"
  resource_group_name       = "${var.rg_name}"
  network_security_group_id = "${var.master_sg_id}"
  count                     = "${var.count}"

  ip_configuration {
    name                          = "${var.cluster_name}-master-ip-${count.index}"
    subnet_id                     = "${var.subnet_id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${element(azurerm_public_ip.master.*.id, count.index)}"
  }
}

resource "azurerm_network_interface" "master-lb" {
  name                      = "${var.cluster_name}-master-lb-ni-${count.index}"
  location                  = "${var.region}"
  resource_group_name       = "${var.rg_name}"
  network_security_group_id = "${var.api_sg_id}"
  count                     = "${var.count}"

  ip_configuration {
    name                          = "${var.cluster_name}-master-lb-ip-${count.index}"
    subnet_id                     = "${var.subnet_id}"
    private_ip_address_allocation = "dynamic"
    load_balancer_backend_address_pools_ids = ["${var.api-lb_bp-id}"]
    #load_balancer_inbound_nat_rules_ids = ["${element(azurerm_lb_nat_rule.winrm_nat.*.id, count.index)}"]
  }
}

resource "azurerm_virtual_machine" "master" {
  name                  = "${var.cluster_name}-master-${count.index}"
  location              = "${var.region}"
  resource_group_name   = "${var.rg_name}"
  network_interface_ids = ["${element(azurerm_network_interface.master.*.id, count.index)}", "${element(azurerm_network_interface.master-lb.*.id, count.index)}"]
  #network_interface_ids = ["${element(azurerm_network_interface.master.*.id, count.index)}"]
  primary_network_interface_id = "${element(azurerm_network_interface.master.*.id, count.index)}"
  vm_size               = "${var.instance_type}"
  availability_set_id   = "${azurerm_availability_set.master.id}"
  depends_on            = ["azurerm_availability_set.master"]
  count                 = "${var.count}"

  storage_image_reference {
    publisher = "CoreOS"
    offer     = "CoreOS"
    sku       = "Stable"
    version   = "${var.image}"
  }

  storage_os_disk {
    name              = "${var.cluster_name}-master-osdisk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.cluster_name}-master-${count.index}"
    admin_username = "${var.os_admin_user}"
    admin_password = "${var.os_adm_passwd}"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.os_admin_user}/.ssh/authorized_keys"
      key_data = "${file("${var.ssh_public_key_file}")}"
    }
  }

  tags {
    environment = "${var.tag_environment}",
    uninett_activity = "${var.tag_activity}"
  }
}

 data "template_file" "masters_ansible" {
     template = "$${name} ansible_host=$${ip} public_ip=$${ip}"
     count = "${var.count}"
     vars {
         name  = "${var.cluster_name}-master-${count.index}"
         ip = "${element(azurerm_public_ip.master.*.id, count.index)}"
     }
 }
