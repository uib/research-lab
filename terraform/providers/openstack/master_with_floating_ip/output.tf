output "list" {
    value = "${join("\n",data.template_file.masters_ansible.*.rendered)}"
}
