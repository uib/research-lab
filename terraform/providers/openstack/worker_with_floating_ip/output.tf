output "list" {
    value = "${join("\n",data.template_file.workers_ansible.*.rendered)}"
}

output "public_ips" {
    value = "${openstack_compute_floatingip_v2.worker.*.address}"
}
