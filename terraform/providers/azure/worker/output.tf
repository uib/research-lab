 output "list" {
     value = "${join("\n",data.template_file.workers_ansible.*.rendered)}"
 }

 output "instances" {
     value = "${azurerm_virtual_machine.worker.*.id}"
 }

 data "template_file" "names" {
     count = "${var.count}"
     template = "${var.cluster_name}-worker-${count.index}"
 }

 output "names" {
     value = "${data.template_file.names.*.rendered}"
 }

 output "public_ips" {
  value =   ["${azurerm_public_ip.worker.*.ip_address}"]
}

 output "private_ips" {
     value = ["${azurerm_network_interface.worker.*.private_ip_address}"]
 }
