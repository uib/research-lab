output "list" {
    value = "${join("\n",data.template_file.workers_ansible.*.rendered)}"
}
