variable "auth_url" {}
variable "domain_name" {}
variable "tenant_name" {}
variable "user_name" {}
variable "password" {}
variable "region" {}
variable "weave_security_group" {}
variable "weave_peers" { type = "list" }
variable "weave_peers_count" {}

provider "openstack" {
    auth_url = "${var.auth_url}"
    domain_name = "${var.domain_name}"
    tenant_name = "${var.tenant_name}"
    user_name = "${var.user_name}"
    password = "${var.password}"
}

resource "openstack_networking_secgroup_rule_v2" "weave_peers_tcp" {
    count = "${var.weave_peers_count}"
    region = "${var.region}"
    direction = "ingress"
    ethertype = "IPv4"
    protocol = "tcp"
    port_range_min = 6783
    port_range_max = 6783
    security_group_id = "${var.weave_security_group}"
    remote_ip_prefix = "${format("%s/32", var.weave_peers[count.index])}"
}

resource "openstack_networking_secgroup_rule_v2" "weave_peers_udp" {
    count = "${var.weave_peers_count}"
    region = "${var.region}"
    direction = "ingress"
    ethertype = "IPv4"
    protocol = "udp"
    port_range_min = 6783
    port_range_max = 6784
    security_group_id = "${var.weave_security_group}"
    remote_ip_prefix = "${format("%s/32", var.weave_peers[count.index])}"
}

# resource "openstack_networking_secgroup_rule_v2" "weave_peers_esp" {
#     count = "${length(var.weave_peers)}"
#     region = "${var.region}"
#     direction = "ingress"
#     ethertype = "IPv4"
#     protocol = "50"
#     security_group_id = "${var.weave_security_group}"
#     remote_ip_prefix = "${format("%s/32", var.weave_peers[count.index])}"
# }
