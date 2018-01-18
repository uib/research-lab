variable "auth_url" {}
variable "domain_name" {}
variable "tenant_name" {}
variable "user_name" {}
variable "password" {}
variable "region" {}
variable "worker_node_flavor" {}
variable "node_flavor" {}
variable "coreos_image" {}
variable "public_v4_network" {}
variable "cluster_name" {}
variable "cluster_dns_domain" {}
variable "allow_ssh_from_v4" { type = "list" }
variable "allow_lb_from_v4" { type = "list" }
variable "allow_api_access_from_v4" { type = "list" }
variable "ssh_public_key" { }
variable "master_count" { }
variable "worker_count" { }
variable "ingress_use_proxy_protocol" {}
variable "master_volume_size" {}
variable "master_volume_name" {}
variable "master_volume_description" {}
variable "worker_volume_size" {}
variable "worker_volume_name" {}
variable "worker_volume_description" {}


provider "openstack" {
    auth_url = "${var.auth_url}"
    domain_name = "${var.domain_name}"
    tenant_name = "${var.tenant_name}"
    user_name = "${var.user_name}"
    password = "${var.password}"
}

module "keypair" {
    source = "../keypair"

    name = "${var.cluster_name}"
    region = "${var.region}"
    pubkey_file = "${var.ssh_public_key}"
}

module "networks" {
    source = "../networks"

    public_v4_network = "${var.public_v4_network}"
    cluster_name = "${var.cluster_name}"
}

module "securitygroups" {
    source = "../securitygroups"

    cluster_name = "${var.cluster_name}"
    region = "${var.region}"
    allow_ssh_from_v4 = "${var.allow_ssh_from_v4}"
    allow_lb_from_v4 = "${var.allow_lb_from_v4}"
    allow_api_access_from_v4 = "${var.allow_api_access_from_v4}"
}

module "masters" {
    source = "../master_with_floating_ip"

    region = "${var.region}"
    flavor = "${var.node_flavor}"
    image = "${var.coreos_image}"
    cluster_name = "${var.cluster_name}"
    count = "${var.master_count}"
    keypair = "${module.keypair.name}"
    network = "${module.networks.id}"
    sec_groups = [ "default", "${module.securitygroups.ssh}", "${module.securitygroups.master}" ]
    master_volume_description = "${var.master_volume_description}"
    master_volume_size = "${var.master_volume_size}"
    master_volume_name = "${var.master_volume_name}"

}

module "workers" {
    source = "../worker_with_floating_ip"

    region = "${var.region}"
    flavor = "${var.worker_node_flavor}"
    image = "${var.coreos_image}"
    cluster_name = "${var.cluster_name}"
    count = "${var.worker_count}"
    keypair = "${module.keypair.name}"
    network = "${module.networks.id}"
    sec_groups = [ "default", "${module.securitygroups.ssh}", "${module.securitygroups.lb}" ]
    worker_volume_description = "${var.worker_volume_description}"
    worker_volume_size = "${var.worker_volume_size}"
    worker_volume_name = "${var.worker_volume_name}"
}
