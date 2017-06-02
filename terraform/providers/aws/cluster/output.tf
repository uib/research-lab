output "master_names" {
    value = "${module.masters.names}"
}

output "master_public_ips" {
    value = "${module.masters.public_ips}"
}

output "master_private_ips" {
    value = "${module.masters.private_ips}"
}


output "worker_names" {
    value = "${module.workers.names}"
}

output "worker_public_ips" {
    value = "${module.workers.public_ips}"
}

output "worker_private_ips" {
    value = "${module.workers.private_ips}"
}
