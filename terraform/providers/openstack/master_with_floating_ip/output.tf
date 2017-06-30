output "list" {
    value = "${join("\n",data.template_file.masters_ansible.*.rendered)}"
}

output "master_ip" {
    value = "${openstack_compute_floatingip_v2.master.0.address}"
}

output "public_ips" {
    value = "${openstack_compute_floatingip_v2.master.*.address}"
}
