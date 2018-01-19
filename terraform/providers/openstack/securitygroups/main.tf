# Security groups

variable "region" {}
variable "cluster_name" {}
variable "allow_ssh_from_v4" { type = "list" }
variable "allow_lb_from_v4" { type = "list" }
variable "allow_api_access_from_v4" { type = "list" }
variable "allow_glusterfs_ssh_from_v4" { type = "list" }
variable "allow_glusterfs_daemon_from_v4" { type = "list" }
variable "allow_glusterfs_mgm_from_v4" { type = "list" }
variable "allow_glusterfs_brick_from_v4" { type = "list" }


resource "openstack_networking_secgroup_v2" "grp_ssh_access" {
    region = "${var.region}"
    name = "${var.cluster_name}-ssh_access"
    description = "Security groups for allowing SSH access"
}

resource "openstack_networking_secgroup_rule_v2" "rule_ssh_access_ipv4" {
    count = "${length(var.allow_ssh_from_v4)}"
    region = "${var.region}"
    direction = "ingress"
    ethertype = "IPv4"
    protocol = "tcp"
    port_range_min = 22
    port_range_max = 22
    remote_ip_prefix = "${element(var.allow_ssh_from_v4, count.index)}"
    security_group_id = "${openstack_networking_secgroup_v2.grp_ssh_access.id}"
}

resource "openstack_networking_secgroup_v2" "glusterfs_ssh_access" {
    region = "${var.region}"
    name = "${var.cluster_name}-glusterfs-ssh_access"
    description = "Security groups for allowing GlusterFS SSH communications"
}

resource "openstack_networking_secgroup_rule_v2" "rule_glusterfs_ssh_access_ipv4" {
    count = "${length(var.allow_glusterfs_ssh_from_v4)}"
    region = "${var.region}"
    direction = "ingress"
    ethertype = "IPv4"
    protocol = "tcp"
    port_range_min = 2222
    port_range_max = 2222
    remote_ip_prefix = "${element(var.allow_glusterfs_ssh_from_v4, count.index)}"
    security_group_id = "${openstack_networking_secgroup_v2.glusterfs_ssh_access.id}"
}

resource "openstack_networking_secgroup_v2" "kube_glusterfs_daemon" {
    region = "${var.region}"
    name = "${var.cluster_name}-glusterfs-daemon"
    description = "Security groups for GlusterFS daemon"
}

resource "openstack_networking_secgroup_rule_v2" "rule_kube_glusterfs_daemon" {
    count = "${length(var.allow_glusterfs_daemon_from_v4)}"
    region = "${var.region}"
    direction = "ingress"
    ethertype = "IPv4"
    protocol = "tcp"
    port_range_min = 24007
    port_range_max = 24007
    remote_ip_prefix = "${element(var.allow_glusterfs_daemon_from_v4, count.index)}"
    security_group_id = "${openstack_networking_secgroup_v2.kube_glusterfs_daemon.id}"
}

resource "openstack_networking_secgroup_v2" "kube_glusterfs_mgm" {
    region = "${var.region}"
    name = "${var.cluster_name}-glusterfs-mgm"
    description = "Security groups for GlusterFS daemon"
}

resource "openstack_networking_secgroup_rule_v2" "rule_kube_glusterfs_mgm_ipv4" {
    count = "${length(var.allow_glusterfs_mgm_from_v4)}"
    region = "${var.region}"
    direction = "ingress"
    ethertype = "IPv4"
    protocol = "tcp"
    port_range_min = 24008
    port_range_max = 24008
    remote_ip_prefix = "${element(var.allow_glusterfs_mgm_from_v4, count.index)}"
    security_group_id = "${openstack_networking_secgroup_v2.kube_glusterfs_mgm.id}"
}

resource "openstack_networking_secgroup_v2" "kube_glusterfs_brick" {
    region = "${var.region}"
    name = "${var.cluster_name}-glusterfs-brick"
    description = "Security groups for GlusterFS brick volume access"
}

resource "openstack_networking_secgroup_rule_v2" "rule_kube_glusterfs_brick_ipv4" {
    count = "${length(var.allow_glusterfs_brick_from_v4)}"
    region = "${var.region}"
    direction = "ingress"
    ethertype = "IPv4"
    protocol = "tcp"
    port_range_min = 49152
    port_range_max = 49252
    remote_ip_prefix = "${element(var.allow_glusterfs_brick_from_v4, count.index)}"
    security_group_id = "${openstack_networking_secgroup_v2.kube_glusterfs_brick.id}"
}

resource "openstack_networking_secgroup_v2" "grp_kube_lb" {
    region = "${var.region}"
    name = "${var.cluster_name}-kube_lb"
    description = "Security groups for allowing web access to lb nodes"
}

resource "openstack_networking_secgroup_rule_v2" "rule_kube_lb_http_ipv4" {
    count = "${length(var.allow_lb_from_v4)}"
    region = "${var.region}"
    direction = "ingress"
    ethertype = "IPv4"
    protocol = "tcp"
    port_range_min = 80
    port_range_max = 80
    remote_ip_prefix = "${element(var.allow_lb_from_v4, count.index)}"
    security_group_id = "${openstack_networking_secgroup_v2.grp_kube_lb.id}"
}

resource "openstack_networking_secgroup_rule_v2" "rule_kube_lb_https_ipv4" {
    count = "${length(var.allow_lb_from_v4)}"
    region = "${var.region}"
    direction = "ingress"
    ethertype = "IPv4"
    protocol = "tcp"
    port_range_min = 443
    port_range_max = 443
    remote_ip_prefix = "${element(var.allow_lb_from_v4, count.index)}"
    security_group_id = "${openstack_networking_secgroup_v2.grp_kube_lb.id}"
}

resource "openstack_networking_secgroup_v2" "grp_kube_master" {
    region = "${var.region}"
    name = "${var.cluster_name}_kube_master"
    description = "Security groups for allowing API access to the master nodes"
}

resource "openstack_networking_secgroup_rule_v2" "rule_kube_master_ipv4" {
    count = "${length(var.allow_api_access_from_v4)}"
    region = "${var.region}"
    direction = "ingress"
    ethertype = "IPv4"
    protocol = "tcp"
    port_range_min = 8443
    port_range_max = 8443
    remote_ip_prefix = "${element(var.allow_api_access_from_v4, count.index)}"
    security_group_id = "${openstack_networking_secgroup_v2.grp_kube_master.id}"
}
