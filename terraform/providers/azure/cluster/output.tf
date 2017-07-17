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
    template = "\n[$${cluster_name}-masters]\n$${master_hosts}\n[$${cluster_name}-workers]\n$${worker_hosts}\n[$${cluster_name}]\ncluster-$${cluster_name}\n[$${cluster_name}:vars]\ncluster_name=$${cluster_name}\ncluster_dns_domain=$${cluster_dns_domain}\ningress_use_proxy_protocol=$${ingress_use_proxy_protocol}\nmaster_ip=$${master_ip}\n[$${cluster_name}:children]\n$${cluster_name}-masters\n$${cluster_name}-workers"
    vars {
        cluster_name = "${var.cluster_name}"
        cluster_dns_domain = "${var.cluster_dns_domain}"
        ingress_use_proxy_protocol = "${var.ingress_use_proxy_protocol}"
        master_ip = "${module.masters.public_ips[0]}"
        #master_ip = "${module.loadbalancers.api-lb_pip}"
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

# output "master_ip" {
#     value = "${module.loadbalancers.api-lb_pip}"
# }

#  output "rg_name" {
#      value = "${module.resourcegroup.rg_name}"
#  }

#output "rg_name" {
#    value = "${azurerm_resource_group.researchlab.name}"
#}
