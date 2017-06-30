variable "access_key" {}
variable "secret_key" {}
variable "region" {}
variable "weave_security_group" {}
variable "weave_peers" { type = "list" }

provider "aws" {
    region = "${var.region}"
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
}

resource "aws_security_group_rule" "weave_peers_tcp" {
    type = "ingress"
    from_port = 6783
    to_port = 6783
    protocol = "tcp"
    cidr_blocks = [ "${formatlist("%s/32", var.weave_peers)}" ]
    security_group_id = "${var.weave_security_group}"
}

resource "aws_security_group_rule" "weave_peers_udp" {
    type = "ingress"
    from_port = 6783
    to_port = 6784
    protocol = "udp"
    cidr_blocks = [ "${formatlist("%s/32", var.weave_peers)}" ]
    security_group_id = "${var.weave_security_group}"
}

resource "aws_security_group_rule" "weave_peers_esp" {
    type = "ingress"
    from_port = 0
    to_port = 0
    protocol = "50"
    cidr_blocks = [ "${formatlist("%s/32", var.weave_peers)}" ]
    security_group_id = "${var.weave_security_group}"
}
