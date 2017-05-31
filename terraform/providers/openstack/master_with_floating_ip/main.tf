variable "region" {}
variable "flavor" {}
variable "image" {}
variable "count" {}
variable "cluster_name" {}
variable "keypair" {}
variable "network" {}
variable "sec_groups" { type = "list" }

# Master nodes
resource "openstack_compute_floatingip_v2" "master" {
    count = "${var.count}"
    region = "${var.region}"
    pool = "public-v4"
}

resource "openstack_compute_instance_v2" "master" {
    count = "${var.count}"
    name = "${var.cluster_name}-master-${count.index}"
    region = "${var.region}"
    image_id = "${var.image}"
    flavor_name = "${var.flavor}"
    key_pair = "${var.keypair}"

    security_groups = ["${var.sec_groups}"]
    user_data = "#cloud-config\nhostname: ${var.cluster_name}-master-${count.index}\n"

    #   Connecting to the set network with the provided floating ip.
    network {
        uuid = "${var.network}"
        floating_ip = "${openstack_compute_floatingip_v2.master.*.address[count.index]}"
    }

    block_device {
        boot_index = 0
        delete_on_termination = true
        source_type = "image"
        destination_type = "local"
        uuid = "${var.image}"
    }
}

data "template_file" "masters_ansible" {
    template = "$${name} ansible_host=$${ip} public_ip=$${ip}"
    count = "${var.count}"
    vars {
        name  = "${openstack_compute_instance_v2.master.*.name[count.index]}"
        ip = "${openstack_compute_floatingip_v2.master.*.address[count.index]}"
    }
}
