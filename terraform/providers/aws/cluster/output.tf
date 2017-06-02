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
    template = "\n[masters]\n$${master_hosts}\n[workers]\n$${worker_hosts}\n[servers:children]\nmasters\nworkers"
    vars {
        master_hosts = "${join("\n",data.template_file.masters_ansible.*.rendered)}"
        worker_hosts = "${join("\n",data.template_file.workers_ansible.*.rendered)}"
    }
}

output "inventory" {
    value = "${data.template_file.inventory.rendered}"
}

