
output "api-lb_bp-id" {
    value = "${azurerm_lb_backend_address_pool.api-lb.id}"
}

output "api-lb_pip" {
    value = "${azurerm_public_ip.api-lb.ip_address}"
}

output "web-lb_bp-id" {
    value = "${azurerm_lb_backend_address_pool.web-lb.id}"
}

output "web-lb_pip" {
    value = "${azurerm_public_ip.web-lb.ip_address}"
}