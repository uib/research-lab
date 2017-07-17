
output "azure_vnet_name" {
    value = "${azurerm_virtual_network.uhsky-researchlab.name}"
}

output "azure_subnet_id" {
    value = "${azurerm_subnet.uhsky-researchlab.id}"
}
