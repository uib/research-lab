 output "list" {
     value = "${join("\n",data.template_file.masters_ansible.*.rendered)}"
 }

 output "instances" {
     value = "${azurerm_virtual_machine.master.*.id}"
 }

 data "template_file" "names" {
     count = "${var.count}"
     template = "${var.cluster_name}-master-${count.index}"
 }

 output "names" {
     value = "${data.template_file.names.*.rendered}"
 }

 output "public_ips" {
  value =   ["${azurerm_public_ip.master.*.ip_address}"]
}

 output "private_ips" {
     value = ["${azurerm_network_interface.master.*.private_ip_address}"]
 }
