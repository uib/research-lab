output "list" {
    value = "${join("\n",data.template_file.masters_ansible.*.rendered)}"
}

output "master_ip" {
    value = "${openstack_compute_instance_v2.master.0.access_ip_v4}"
}
