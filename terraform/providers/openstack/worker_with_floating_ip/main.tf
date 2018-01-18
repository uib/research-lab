variable "region" {}
variable "flavor" {}
variable "image" {}
variable "count" {}
variable "cluster_name" {}
variable "keypair" {}
variable "network" {}
variable "sec_groups" { type = "list" }
variable "worker_volume_size" {}
variable "worker_volume_name" {}
variable "worker_volume_description" {}

# Worker nodes
resource "openstack_compute_floatingip_v2" "worker" {
    count = "${var.count}"
    region = "${var.region}"
    pool = "public-v4"
}
resource "openstack_compute_instance_v2" "worker" {
    count = "${var.count}"
    name = "${var.cluster_name}-worker-${count.index}"
    region = "${var.region}"
    flavor_name = "${var.flavor}"
    key_pair = "${var.keypair}"

    security_groups = ["${var.sec_groups}"]
    user_data = "#cloud-config\nhostname: ${var.cluster_name}-worker-${count.index}\n"

    #   Connecting to the set network with the provided floating ip.
    network {
        uuid = "${var.network}"
    }

    block_device {
        boot_index = 0
        delete_on_termination = true
        source_type = "image"
        destination_type = "volume"
        uuid = "${var.image}"
        volume_size = 40
    }
}

resource "openstack_compute_floatingip_associate_v2" "worker" {
    count = "${var.count}"
    floating_ip = "${openstack_compute_floatingip_v2.worker.*.address[count.index]}"
    instance_id = "${openstack_compute_instance_v2.worker.*.id[count.index]}"
}

resource "openstack_blockstorage_volume_v2" "worker_volume" {
  region      = "${var.region}"
  name        = "${var.worker_volume_name}-glusterfs-volume-${count.index}"
  description = "${var.worker_volume_description}"
  size        = "${var.worker_volume_size}"
}

data "template_file" "workers_ansible" {
    template = "$${name} ansible_host=$${ip} lb=$${lb_flag}"
    count = "${var.count}"
    vars {
        name  = "${openstack_compute_instance_v2.worker.*.name[count.index]}"
        ip = "${openstack_compute_floatingip_v2.worker.*.address[count.index]}"
        lb_flag = "${count.index < 3 ? "true" : "false"}"
    }
}
