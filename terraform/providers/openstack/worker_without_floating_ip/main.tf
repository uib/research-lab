variable "region" {}
variable "flavor" {}
variable "image" {}
variable "count" {}
variable "cluster_name" {}
variable "keypair" {}
variable "network" {}
variable "sec_groups" { type = "list" }
variable "availability_zone" {}
variable "worker_volume_size" {}
variable "worker_volume_name" {}
variable "worker_volume_description" {}

# Worker nodes
resource "openstack_compute_instance_v2" "worker" {
    count = "${var.count}"
    name = "${var.cluster_name}-worker-${count.index}"
    region = "${var.region}"
    flavor_name = "${var.flavor}"
    image_id = "${var.image}"
    key_pair = "${var.keypair}"
    availability_zone = "${var.availability_zone}"
    network = {
      name = "${var.network}"
    }

    security_groups = ["${var.sec_groups}"]
    user_data = "#cloud-config\nhostname: ${var.cluster_name}-worker-${count.index}\n"

    block_device {
        boot_index = 0
        delete_on_termination = true
        source_type = "image"
        destination_type = "local"
        uuid = "${var.image}"
        #volume_size = 40
    }

    timeouts {
    create = "3m"
    delete = "3m"
  }
}

resource "openstack_blockstorage_volume_v2" "worker_volume" {
  count       = "${var.count}"
  region      = "${var.region}"
  name        = "${var.worker_volume_name}-glusterfs-volume-${count.index}"
  description = "${var.worker_volume_description}"
  size        = "${var.worker_volume_size}"

   timeouts {
   create = "3m"
   delete = "3m"
 }
}

resource "openstack_compute_volume_attach_v2" "worker_volumes" {
  count       = "${var.count}"
  region      = "${var.region}"
  instance_id = "${element(openstack_compute_instance_v2.worker.*.id, count.index)}"
  volume_id   = "${element(openstack_blockstorage_volume_v2.worker_volume.*.id, count.index)}"
  //device      =  "/dev/vdx"

   timeouts {
   create = "3m"
   delete = "3m"
 }
}


data "template_file" "workers_ansible" {
    template = "$${name} ansible_host=$${ip} lb=$${lb_flag}"
    count = "${var.count}"
    vars {
        name  = "${openstack_compute_instance_v2.worker.*.name[count.index]}"
        ip = "${element(openstack_compute_instance_v2.worker.*.access_ip_v4, count.index)}"
        lb_flag = "${count.index < 3 ? "true" : "false"}"
    }
}
