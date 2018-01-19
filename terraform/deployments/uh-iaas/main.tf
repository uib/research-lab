provider "openstack" {
    auth_url = "${var.auth_url}"
    domain_name = "${var.domain_name}"
    tenant_name = "${var.tenant_name}"
    user_name = "${var.user_name}"
    password = "${var.password}"
}

module "global" {
    source = "../../global-vars"

    cluster_name = "${var.cluster_name}"
    cluster_dns_domain = "${var.cluster_dns_domain}"
    allow_ssh_from_v4 = "${var.allow_ssh_from_v4}"
    allow_lb_from_v4 = "${var.allow_lb_from_v4}"
    allow_api_access_from_v4 = "${var.allow_api_access_from_v4}"
    ssh_public_key = "${var.ssh_public_key}"
    master_count = "${var.master_count}"
    worker_count = "${var.worker_count}"
    ingress_use_proxy_protocol = "${var.ingress_use_proxy_protocol}"
}

module "cluster" {
    source = "../../providers/openstack/cluster_without_floating_ip"

    auth_url = "${var.auth_url}"
    domain_name = "${var.domain_name}"
    tenant_name = "${var.tenant_name}"
    user_name = "${var.user_name}"
    password = "${var.password}"
    region = "${var.region}"
    worker_node_flavor = "${var.worker_node_flavor}"
    node_flavor = "${var.node_flavor}"
    coreos_image = "${var.coreos_image}"
    network = "${var.network}"
    availability_zone = "${var.availability_zone}"
    cluster_name = "${module.global.cluster_name}"
    cluster_dns_domain = "${var.cluster_dns_domain}"
    allow_ssh_from_v4 = "${module.global.allow_ssh_from_v4}"
    allow_lb_from_v4 = "${module.global.allow_lb_from_v4}"
    allow_api_access_from_v4 = "${module.global.allow_api_access_from_v4}"
    ssh_public_key = "${module.global.ssh_public_key}"
    master_count = "${module.global.master_count}"
    worker_count = "${module.global.worker_count}"
    ingress_use_proxy_protocol = "${module.global.ingress_use_proxy_protocol}"
    worker_volume_description = "${var.worker_volume_description}"
    worker_volume_size = "${var.worker_volume_size}"
    worker_volume_name = "${var.worker_volume_name}"
    master_volume_description = "${var.master_volume_description}"
    master_volume_size = "${var.master_volume_size}"
    master_volume_name = "${var.master_volume_name}"
    allow_glusterfs_ssh_from_v4 = "${var.allow_glusterfs_ssh_from_v4}"
    allow_glusterfs_daemon_from_v4 = "${var.allow_glusterfs_daemon_from_v4}"
    allow_glusterfs_mgm_from_v4 = "${var.allow_glusterfs_mgm_from_v4}"
    allow_glusterfs_brick_from_v4 = "${var.allow_glusterfs_brick_from_v4}"
}

data "template_file" "inventory_tail" {
    template = "[all:children]\n$${cluster_name}\n\n[masters:children]\n$${cluster_name}-masters\n[workers:children]\n$${cluster_name}-workers\n[servers:children]\nmasters\nworkers\n[servers:vars]\nansible_ssh_user=core\nansible_python_interpreter=/home/core/bin/python\n"
    vars = {
        cluster_name = "${var.cluster_name}"
    }
}

data "template_file" "inventory" {
    template = "$${cluster}\n$${inventory_tail}"
    vars {
        cluster = "${module.cluster.inventory}"
        inventory_tail = "${data.template_file.inventory_tail.rendered}"
    }
}

output "inventory" {
    value = "${data.template_file.inventory.rendered}"
}
