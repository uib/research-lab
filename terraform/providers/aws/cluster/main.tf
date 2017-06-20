variable "access_key" {}
variable "secret_key" {}
variable "region" {}
variable "cluster_name" {}
variable "coreos_image" {}
variable "master_instance_type" {}
variable "master_count" {}
variable "worker_instance_type" {}
variable "worker_count" {}
variable "ssh_public_key_file" {}
variable "allow_ssh_from_v4" { type = "list" }
variable "allow_lb_from_v4" { type = "list" }
variable "allow_api_access_from_v4" { type = "list" }

provider "aws" {
    region = "${var.region}"
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
}

module "keypair" {
    source = "../keypair"

    name = "researchlab-${var.cluster_name}"
    pubkey_file = "${var.ssh_public_key_file}"
}

module "networks" {
    source = "../networks"

    cluster_name = "${var.cluster_name}"
}

module "securitygroups" {
    source = "../securitygroups"

    vpc_id = "${module.networks.id}"
    cluster_name = "${var.cluster_name}"
    allow_ssh_from_v4 = "${var.allow_ssh_from_v4}"
    allow_lb_from_v4 = "${var.allow_lb_from_v4}"
    allow_api_access_from_v4 = "${var.allow_api_access_from_v4}"
}

module "masters" {
    source = "../master"

    instance_type = "${var.master_instance_type}"
    image = "${var.coreos_image}"
    cluster_name = "${var.cluster_name}"
    count = "${var.master_count}"
    key_name = "${module.keypair.name}"
    subnets = "${module.networks.subnets}"
    sec_groups = [ "${module.networks.security_group_default}", "${module.securitygroups.ssh}", "${module.securitygroups.master}" ]
}

module "workers" {
    source = "../worker"

    instance_type = "${var.worker_instance_type}"
    image = "${var.coreos_image}"
    cluster_name = "${var.cluster_name}"
    count = "${var.worker_count}"
    key_name = "${module.keypair.name}"
    subnets = "${module.networks.subnets}"
    sec_groups = [ "${module.networks.security_group_default}", "${module.securitygroups.ssh}", "${module.securitygroups.lb}" ]
}

module "loadbalancers" {
    source = "../loadbalancer"

    cluster_name = "${var.cluster_name}"
    subnets = "${module.networks.subnets}"
    sec_group_api_lb = [ "${module.securitygroups.api_lb}" ]
    sec_group_web_lb = [ "${module.securitygroups.web_lb}" ]
    masters = "${module.masters.instances}"
    workers = "${module.workers.instances}"
}
