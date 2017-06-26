output "cluster_name" {
    value = "${var.cluster_name}"
}


output "cluster_dns_domain" {
    value = "${var.cluster_dns_domain}"
}

output "allow_ssh_from_v4" {
    value = ["${split(",", length(var.allow_ssh_from_v4) > 0 ? join(",", var.allow_ssh_from_v4) : join(",", var.default_acl))}"]
}

output "allow_lb_from_v4" {
    value = ["${split(",", length(var.allow_lb_from_v4) > 0 ? join(",", var.allow_lb_from_v4) : join(",", var.default_acl))}"]
}

output "allow_api_access_from_v4" {
    value = ["${split(",", length(var.allow_api_access_from_v4) > 0 ? join(",", var.allow_api_access_from_v4) : join(",", var.default_acl))}"]
}

output "ssh_public_key" {
    value = "${var.ssh_public_key != "" ? var.ssh_public_key : var.default_ssh_key}"
}

output "ingress_use_proxy_protocol" {
    value = "${var.ingress_use_proxy_protocol != "" ? var.ingress_use_proxy_protocol : var.default_ingress_use_proxy_protocol}"
}

output "master_count" {
    value = "${var.master_count > 0 ? var.master_count : var.default_master_count}"
}

output "worker_count" {
    value = "${var.worker_count > 0 ? var.worker_count : var.default_worker_count}"
}
