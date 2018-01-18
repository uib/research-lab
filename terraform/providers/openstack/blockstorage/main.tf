variable "region" {}
variable "size" {}
variable "name" {}
variable "description" {}


resource "openstack_blockstorage_volume_v2" "node_volume" {
  region      = "${var.region}"
  name        = "${var.name}-node-volume-${count.index}"
  description = "${var.description}"
  size        = "${var.size}"
}
