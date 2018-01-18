variable "region" {}
variable "flavor" {}
variable "image" {}
variable "count" {}
variable "cluster_name" {}
variable "keypair" {}
variable "network" {}
variable "sec_groups" { type = "list" }
variable "master_volume_size" {}
variable "master_volume_name" {}
variable "master_volume_description" {}

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

    #   Connecting to the set network
    network {
        uuid = "${var.network}"
    }

    block_device {
        boot_index = 0
        delete_on_termination = true
        source_type = "image"
        destination_type = "local"
        uuid = "${var.image}"
    }
}

resource "openstack_compute_floatingip_associate_v2" "master" {
    count = "${var.count}"
    floating_ip = "${openstack_compute_floatingip_v2.master.*.address[count.index]}"
    instance_id = "${openstack_compute_instance_v2.master.*.id[count.index]}"
}

resource "openstack_blockstorage_volume_v2" "worker_volume" {
  region      = "${var.region}"
  name        = "${var.master_volume_name}-glusterfs-volume-${count.index}"
  description = "${var.master_volume_description}"
  size        = "${var.master_volume_size}"
}

data "template_file" "masters_ansible" {
    template = "$${name} ansible_host=$${ip} public_ip=$${ip}"
    count = "${var.count}"
    vars {
        name  = "${openstack_compute_instance_v2.master.*.name[count.index]}"
        ip = "${openstack_compute_floatingip_v2.master.*.address[count.index]}"
    }
}
