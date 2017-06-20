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

module "networks" {
    source = "../../providers/openstack/networks"

    public_v4_network = "${var.public_v4_network}"
    cluster_name = "${module.global.cluster_name}"
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
    source = "../../providers/openstack/master_with_floating_ip"

    region = "${var.region}"
    flavor = "${var.node_flavor}"
    image = "${var.coreos_image}"
    cluster_name = "${module.global.cluster_name}"
    count = "${module.global.master_count}"
    keypair = "${module.keypair.name}"
    network = "${module.networks.id}"
    sec_groups = [ "default", "${module.securitygroups.ssh}", "${module.securitygroups.master}" ]
}

module "workers" {
    source = "../../providers/openstack/worker_with_floating_ip"

    region = "${var.region}"
    flavor = "${var.worker_node_flavor}"
    image = "${var.coreos_image}"
    cluster_name = "${module.global.cluster_name}"
    count = "${module.global.worker_count}"
    keypair = "${module.keypair.name}"
    network = "${module.networks.id}"
    sec_groups = [ "default", "${module.securitygroups.ssh}", "${module.securitygroups.lb}" ]
}

data "template_file" "cluster" {
    template = "[$${cluster_name}-masters]\n$${master_hosts}\n[$${cluster_name}-workers]\n$${worker_hosts}\n[$${cluster_name}]\ncluster-$${cluster_name}\n[$${cluster_name}:children]\n$${cluster_name}-masters\n$${cluster_name}-workers\n[$${cluster_name}:vars]\nmaster_ip=$${master_ip}\ncluster_name=$${cluster_name}\ncluster_dns_domain=$${cluster_dns_domain}\ningress_use_proxy_protocol=$${ingress_use_proxy_protocol}\nmaster_ip=$${master_ip}\n"
    vars {
        cluster_name = "${var.cluster_name}"
        cluster_dns_domain = "${var.cluster_dns_domain}"
        ingress_use_proxy_protocol = "${module.global.ingress_use_proxy_protocol}"
        master_ip = "${module.masters.master_ip}"
        master_hosts = "${module.masters.list}"
        worker_hosts = "${module.workers.list}"
    }
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
        cluster = "${data.template_file.cluster.rendered}"
        inventory_tail = "${data.template_file.inventory_tail.rendered}"
    }
}

output "inventory" {
    value = "${data.template_file.inventory.rendered}"
}
