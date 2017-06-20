data "template_file" "masters_ansible" {
    template = "$${name} ansible_host=$${ip} public_ip=$${ip}"
    count = "${var.master_count}"
    vars {
        name  = "${module.masters.names[count.index]}"
        ip = "${module.masters.public_ips[count.index]}"
    }
}

data "template_file" "workers_ansible" {
    template = "$${name} ansible_host=$${ip} lb=$${lb_flag}"
    count = "${var.worker_count}"
    vars {
        name  = "${module.workers.names[count.index]}"
        ip = "${module.workers.public_ips[count.index]}"
        lb_flag = "${count.index < 3 ? "true" : "false"}"
    }
}

data "template_file" "inventory" {
    template = "\n[$${cluster_name}-masters]\n$${master_hosts}\n[$${cluster_name}-workers]\n$${worker_hosts}\n[$${cluster_name}:children]\n$${cluster_name}-masters\n$${cluster_name}-workers"
    vars {
        cluster_name = "${var.cluster_name}"
        master_hosts = "${join("\n",data.template_file.masters_ansible.*.rendered)}"
        worker_hosts = "${join("\n",data.template_file.workers_ansible.*.rendered)}"
    }
}

output "inventory" {
    value = "${data.template_file.inventory.rendered}"
}

output "master_ip" {
    value = "${module.masters.public_ips[0]}"
}
