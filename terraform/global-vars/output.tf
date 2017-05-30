output "cluster_name" {
    value = "${var.cluster_name}"
}

output "cluster_dns_domain" {
    value = "${var.cluster_dns_domain}"
}

output "allow_ssh_from_v4" {
    value = "${var.allow_ssh_from_v4}"
}

output "allow_lb_from_v4" {
    value = "${var.allow_lb_from_v4}"
}

output "allow_api_access_from_v4" {
    value = "${var.allow_api_access_from_v4}"
}

output "ssh_public_key" {
    value = "${var.ssh_public_key}"
}

output "master_count" {
    value = "${var.master_count}"
}

output "worker_count" {
    value = "${var.worker_count}"
}
