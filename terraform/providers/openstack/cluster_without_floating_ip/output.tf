data "template_file" "inventory" {
    template = "[$${cluster_name}-masters]\n$${master_hosts}\n[$${cluster_name}-workers]\n$${worker_hosts}\n[$${cluster_name}]\ncluster-$${cluster_name}\n[$${cluster_name}:children]\n$${cluster_name}-masters\n$${cluster_name}-workers\n[$${cluster_name}:vars]\nmaster_ip=$${master_ip}\ncluster_name=$${cluster_name}\ncluster_dns_domain=$${cluster_dns_domain}\ningress_use_proxy_protocol=$${ingress_use_proxy_protocol}\nmaster_ip=$${master_ip}\n"
    vars {
        cluster_name = "${var.cluster_name}"
        cluster_dns_domain = "${var.cluster_dns_domain}"
        ingress_use_proxy_protocol = "${var.ingress_use_proxy_protocol}"
        master_ip = "${module.masters.master_ip}"
        master_hosts = "${module.masters.list}"
        worker_hosts = "${module.workers.list}"
    }
}

output "inventory" {
    value = "${data.template_file.inventory.rendered}"
}

output "master_ips" {
    value = "${module.masters.public_ips}"
}

output "worker_ips" {
    value = "${module.workers.public_ips}"
}

output "weave_security_group" {
    value = "${module.securitygroups.weave_id}"
}
