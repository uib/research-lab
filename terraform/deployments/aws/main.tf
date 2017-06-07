provider "aws" {
  region     = "eu-central-1"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
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

module "keypair" {
    source = "../../providers/aws/keypair"

    name = "researchlab-${module.global.cluster_name}"
    pubkey_file = "${module.global.ssh_public_key}"
}

module "networks" {
    source = "../../providers/aws/networks"

    cluster_name = "${module.global.cluster_name}"
}

module "securitygroups" {
    source = "../../providers/aws/securitygroups"

    vpc_id = "${module.networks.id}"
    cluster_name = "${module.global.cluster_name}"
    allow_ssh_from_v4 = "${module.global.allow_ssh_from_v4}"
    allow_lb_from_v4 = "${module.global.allow_lb_from_v4}"
    allow_api_access_from_v4 = "${module.global.allow_api_access_from_v4}"
}

module "masters" {
    source = "../../providers/aws/master"

    instance_type = "${var.master_instance_type}"
    image = "${var.coreos_image}"
    cluster_name = "${module.global.cluster_name}"
    count = "${module.global.master_count}"
    key_name = "${module.keypair.name}"
    subnets = "${module.networks.subnets}"
    sec_groups = [ "${module.networks.security_group_default}", "${module.securitygroups.ssh}", "${module.securitygroups.master}" ]
}

module "workers" {
    source = "../../providers/aws/worker"

    instance_type = "${var.worker_instance_type}"
    image = "${var.coreos_image}"
    cluster_name = "${module.global.cluster_name}"
    count = "${module.global.worker_count}"
    key_name = "${module.keypair.name}"
    subnets = "${module.networks.subnets}"
    sec_groups = [ "${module.networks.security_group_default}", "${module.securitygroups.ssh}", "${module.securitygroups.lb}" ]
}

module "loadbalancers" {
    source = "../../providers/aws/loadbalancer"

    cluster_name = "${module.global.cluster_name}"
    subnets = "${module.networks.subnets}"
    sec_group_api_lb = [ "${module.securitygroups.api_lb}" ]
    sec_group_web_lb = [ "${module.securitygroups.web_lb}" ]
    masters = "${module.masters.instances}"
    workers = "${module.workers.instances}"
}

data "template_file" "inventory_tail" {
    template = "$${section_children}\n$${section_vars}"
    vars = {
        section_children = "[servers:children]\nmasters\nworkers"
        section_vars = "[servers:vars]\nansible_ssh_user=core\nansible_python_interpreter=/home/core/bin/python\n[all]\ncluster\n[all:children]\nservers\n[all:vars]\ncluster_name=${var.cluster_name}\ncluster_dns_domain=${var.cluster_dns_domain}\ningress_use_proxy_protocol=${module.global.ingress_use_proxy_protocol}\n"
    }
}

data "template_file" "inventory" {
    template = "\n[masters]\n$${master_hosts}\n[workers]\n$${worker_hosts}\n$${inventory_tail}"
    vars {
        master_hosts = "${module.masters.list}"
        worker_hosts = "${module.workers.list}"
        inventory_tail = "${data.template_file.inventory_tail.rendered}"
    }
}

output "inventory" {
    value = "${data.template_file.inventory.rendered}"
}
