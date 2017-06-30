output "list" {
    value = "${join("\n",data.template_file.workers_ansible.*.rendered)}"
}

output "public_ips" {
    value = "${openstack_compute_instance_v2.worker.*.access_ip_v4}"
}
