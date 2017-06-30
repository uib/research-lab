output "ssh" {
    value = "${openstack_networking_secgroup_v2.grp_ssh_access.name}"
}

output "lb" {
    value = "${openstack_networking_secgroup_v2.grp_kube_lb.name}"
}

output "master" {
    value = "${openstack_networking_secgroup_v2.grp_kube_master.name}"
}

output "weave" {
    value = "${openstack_networking_secgroup_v2.grp_weave_peers.name}"
}

output "weave_id" {
    value = "${openstack_networking_secgroup_v2.grp_weave_peers.id}"
}
