variable "region" {}
variable "flavor" {}
variable "image" {}
variable "count" {}
variable "cluster_name" {}
variable "keypair" {}
variable "network" {}
variable "sec_groups" { type = "list" }
variable "availability_zone" {}
variable "master_volume_size" {}
variable "master_volume_name" {}
variable "master_volume_description" {}

# Master nodes
resource "openstack_compute_instance_v2" "master" {
    count = "${var.count}"
    name = "${var.cluster_name}-master-${count.index}"
    region = "${var.region}"
    image_id = "${var.image}"
    flavor_name = "${var.flavor}"
    key_pair = "${var.keypair}"
    availability_zone = "${var.availability_zone}"

    network = {
      name = "${var.network}"
    }

    security_groups = ["${var.sec_groups}"]
    user_data = "#cloud-config\nhostname: ${var.cluster_name}-master-${count.index}\n"

    block_device {
        boot_index = 0
        delete_on_termination = true
        source_type = "image"
        destination_type = "local"
        uuid = "${var.image}"
    }
}

resource "openstack_blockstorage_volume_v2" "master_volume" {
  count       = "${var.count}"
  region      = "${var.region}"
  name        = "${var.master_volume_name}-glusterfs-volume-${count.index}"
  description = "${var.master_volume_description}"
  size        = "${var.master_volume_size}"

   timeouts {
   create = "3m"
   delete = "3m"
 }
}

resource "openstack_compute_volume_attach_v2" "master_volumes" {
  count       = "${var.count}"
  region      = "${var.region}"
  instance_id = "${element(openstack_compute_instance_v2.master.*.id, count.index)}"
  volume_id   = "${element(openstack_blockstorage_volume_v2.master_volume.*.id, count.index)}"
  //device      =  "/dev/vdx"

   timeouts {
   create = "3m"
   delete = "3m"
 }
}

data "template_file" "masters_ansible" {
    template = "$${name} ansible_host=$${ip} public_ip=$${ip}"
    count = "${var.count}"
    vars {
        name  = "${openstack_compute_instance_v2.master.*.name[count.index]}"
        ip = "${element(openstack_compute_instance_v2.master.*.access_ip_v4, count.index)}"
    }
}
