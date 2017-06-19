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

module "keypair" {
    source = "../../providers/openstack/keypair"

    name = "${module.global.cluster_name}"
    region = "${var.region}"
    pubkey_file = "${module.global.ssh_public_key}"
}

module "securitygroups" {
    source = "../../providers/openstack/securitygroups"

    cluster_name = "${module.global.cluster_name}"
    region = "${var.region}"
    allow_ssh_from_v4 = "${module.global.allow_ssh_from_v4}"
    allow_lb_from_v4 = "${module.global.allow_lb_from_v4}"
    allow_api_access_from_v4 = "${module.global.allow_api_access_from_v4}"
}

module "masters" {
    source = "../../providers/openstack/master_without_floating_ip"

    region = "${var.region}"
    flavor = "${var.node_flavor}"
    image = "${var.coreos_image}"
    availability_zone = "${var.availability_zone}"
    cluster_name = "${module.global.cluster_name}"
    count = "${module.global.master_count}"
    keypair = "${module.keypair.name}"
    sec_groups = [ "default", "${module.securitygroups.ssh}", "${module.securitygroups.master}" ]
}

module "workers" {
    source = "../../providers/openstack/worker_without_floating_ip"

    region = "${var.region}"
    flavor = "${var.worker_node_flavor}"
    image = "${var.coreos_image}"
    availability_zone = "${var.availability_zone}"
    cluster_name = "${module.global.cluster_name}"
    count = "${module.global.worker_count}"
    keypair = "${module.keypair.name}"
    sec_groups = [ "default", "${module.securitygroups.ssh}", "${module.securitygroups.lb}" ]
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
