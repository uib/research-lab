output "list" {
    value = "${join("\n",data.template_file.workers_ansible.*.rendered)}"
}

output "instances" {
    value = "${aws_instance.worker.*.id}"
}

data "template_file" "names" {
    count = "${var.count}"
    template = "${var.cluster_name}-worker-${count.index}"
}

output "names" {
    value = "${data.template_file.names.*.rendered}"
}

output "public_ips" {
    value = "${aws_eip.worker.*.public_ip}"
}

output "private_ips" {
    value = "${aws_instance.worker.*.private_ip}"
}
