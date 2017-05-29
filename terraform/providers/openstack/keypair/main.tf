variable "name" {}
variable "region" {}
variable "pubkey_file" {}

resource "openstack_compute_keypair_v2" "keypair" {
    name = "${var.name}"
    region = "${var.region}"
    public_key = "${file(var.pubkey_file)}"
}
