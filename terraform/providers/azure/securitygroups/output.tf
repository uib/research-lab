output "master_sg_id" {
    value = "${azurerm_network_security_group.master-sg.id}"
}

output "worker_sg_id" {
    value = "${azurerm_network_security_group.worker-sg.id}"
}

#output "api_sg_id" {
#    value = "${azurerm_network_security_group.api-sg.id}"
#}

#output "web_sg_id" {
#    value = "${azurerm_network_security_group.web-sg.id}"
#}
