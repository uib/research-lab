output "list" {
    value = "${join("\n",data.template_file.masters_ansible.*.rendered)}"
}

output "instances" {
    value = "${aws_instance.master.*.id}"
}
