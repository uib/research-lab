output "list" {
    value = "${join("\n",data.template_file.masters_ansible.*.rendered)}"
}

output "instances" {
    value = "${aws_instance.master.*.id}"
}

data "template_file" "names" {
    count = "${var.count}"
    template = "${var.cluster_name}-master-${count.index}"
}

output "names" {
    value = "${data.template_file.names.*.rendered}"
}

output "public_ips" {
    value = "${aws_eip.master.*.public_ip}"
}

output "private_ips" {
    value = "${aws_instance.master.*.private_ip}"
}
