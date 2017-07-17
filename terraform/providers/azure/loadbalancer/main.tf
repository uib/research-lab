variable "rg_name" {}
variable "region" {}
variable "cluster_name" {}

# https://docs.microsoft.com/en-us/azure/load-balancer/load-balancer-overview

########################### API LB ###########################

resource "azurerm_public_ip" "api-lb" {
  name                         = "${var.cluster_name}_api-lb_pip"
  location                     = "${var.region}"
  resource_group_name          = "${var.rg_name}"
  public_ip_address_allocation = "static"
}

# Front End Load Balancer
resource "azurerm_lb" "api-lb" {
  name                = "${var.cluster_name}_api-lb"
  location            = "${var.region}"
  resource_group_name = "${var.rg_name}"

  frontend_ip_configuration {
    name                 = "${var.cluster_name}_api-lb_ip-config"
    public_ip_address_id = "${azurerm_public_ip.api-lb.id}"
  }
}

# Back End Address Pool
resource "azurerm_lb_backend_address_pool" "api-lb" {
  resource_group_name = "${var.rg_name}"
  loadbalancer_id     = "${azurerm_lb.api-lb.id}"
  name                = "${var.cluster_name}_api-lb_backend_address_pool"
}

# Load Balancer Rule
resource "azurerm_lb_rule" "api-lb_kubectl" {
  resource_group_name            = "${var.rg_name}"
  loadbalancer_id                = "${azurerm_lb.api-lb.id}"
  name                           = "kubectl_rule"
  protocol                       = "Tcp"
  frontend_port                  = 8443
  backend_port                   = 8443
  frontend_ip_configuration_name = "${var.cluster_name}_api-lb_ip-config"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.api-lb.id}"
  probe_id                       = "${azurerm_lb_probe.api-lb.id}"
  depends_on                     = ["azurerm_lb_probe.api-lb"]
}

#LB Probe - Checks to see which VMs are healthy and available
resource "azurerm_lb_probe" "api-lb" {
  resource_group_name = "${var.rg_name}"
  loadbalancer_id     = "${azurerm_lb.api-lb.id}"
  protocol            = "Tcp"
  name                = "kubectl_probe"
  port                = 8443
}

########################### WEB LB ###########################

resource "azurerm_public_ip" "web-lb" {
  name                         = "${var.cluster_name}_web-lb_pip"
  location                     = "${var.region}"
  resource_group_name          = "${var.rg_name}"
  public_ip_address_allocation = "static"
}

# Front End Load Balancer
resource "azurerm_lb" "web-lb" {
  name                = "${var.cluster_name}_web-lb"
  location            = "${var.region}"
  resource_group_name = "${var.rg_name}"

  frontend_ip_configuration {
    name                 = "${var.cluster_name}_web-lb_ip-config"
    public_ip_address_id = "${azurerm_public_ip.web-lb.id}"
  }
}

# Back End Address Pool
resource "azurerm_lb_backend_address_pool" "web-lb" {
  resource_group_name = "${var.rg_name}"
  loadbalancer_id     = "${azurerm_lb.web-lb.id}"
  name                = "${var.cluster_name}_web-lb_backend_address_pool"
}

# Load Balancer Rule
resource "azurerm_lb_rule" "web-lb_http" {
  resource_group_name            = "${var.rg_name}"
  loadbalancer_id                = "${azurerm_lb.web-lb.id}"
  name                           = "http_rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "${var.cluster_name}_web-lb_ip-config"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.web-lb.id}"
  probe_id                       = "${azurerm_lb_probe.web-lb.id}"
  depends_on                     = ["azurerm_lb_probe.web-lb"]
}

resource "azurerm_lb_rule" "web-lb_https" {
  resource_group_name            = "${var.rg_name}"
  loadbalancer_id                = "${azurerm_lb.web-lb.id}"
  name                           = "https_rule"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "${var.cluster_name}_web-lb_ip-config"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.web-lb.id}"
  probe_id                       = "${azurerm_lb_probe.web-lb.id}"
  depends_on                     = ["azurerm_lb_probe.web-lb"]
}

#LB Probe - Checks to see which VMs are healthy and available
resource "azurerm_lb_probe" "web-lb" {
  resource_group_name = "${var.rg_name}"
  loadbalancer_id     = "${azurerm_lb.web-lb.id}"
  protocol            = "Tcp"
  name                = "http_probe"
  port                = 80
}