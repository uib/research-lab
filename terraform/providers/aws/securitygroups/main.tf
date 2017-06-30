# Security groups

variable "cluster_name" {}
variable "vpc_id" {}
variable "allow_ssh_from_v4" { type = "list" }
variable "allow_lb_from_v4" { type = "list" }
variable "allow_api_access_from_v4" { type = "list" }

resource "aws_security_group" "grp_ssh_access" {
    name = "${var.cluster_name}-ssh_access"
    description = "Security groups for allowing SSH access"
    vpc_id = "${var.vpc_id}"
}

resource "aws_security_group_rule" "rule_ssh_access_ipv4" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ "${var.allow_ssh_from_v4}" ]
    security_group_id = "${aws_security_group.grp_ssh_access.id}"
}

resource "aws_security_group" "api_lb" {
    name = "${var.cluster_name}-api_lb"
    description = "Security groups for API load balancer"
    vpc_id = "${var.vpc_id}"
}

resource "aws_security_group_rule" "api_lb_https" {
    type = "ingress"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = "${var.allow_api_access_from_v4}"
    security_group_id = "${aws_security_group.api_lb.id}"
}

resource "aws_security_group_rule" "api_lb_outbound" {
    type = "egress"
    protocol = "all"
    from_port = 0
    to_port = 65535
    cidr_blocks = [ "0.0.0.0/0" ]
    security_group_id = "${aws_security_group.api_lb.id}"
}

resource "aws_security_group" "web_lb" {
    name = "${var.cluster_name}-web_lb"
    description = "Security groups for web ingress load balancer"
    vpc_id = "${var.vpc_id}"
}

resource "aws_security_group_rule" "web_lb_http" {
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
    security_group_id = "${aws_security_group.web_lb.id}"
}

resource "aws_security_group_rule" "web_lb_https" {
    type = "ingress"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
    security_group_id = "${aws_security_group.web_lb.id}"
}

resource "aws_security_group_rule" "web_lb_outbound" {
    type = "egress"
    protocol = "all"
    from_port = 0
    to_port = 65535
    cidr_blocks = [ "0.0.0.0/0" ]
    security_group_id = "${aws_security_group.web_lb.id}"
}

resource "aws_security_group" "grp_kube_lb" {
    name = "${var.cluster_name}-kube_lb"
    description = "Security groups for allowing web access to lb nodes"
    vpc_id = "${var.vpc_id}"
}

resource "aws_security_group_rule" "rule_kube_lb_http_ipv4" {
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = "${var.allow_lb_from_v4}"
    security_group_id = "${aws_security_group.grp_kube_lb.id}"
}

resource "aws_security_group_rule" "rule_kube_lb_https_ipv4" {
    type = "ingress"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = "${var.allow_lb_from_v4}"
    security_group_id = "${aws_security_group.grp_kube_lb.id}"
}

resource "aws_security_group_rule" "rule_kube_lb_http_web_lb" {
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    source_security_group_id = "${aws_security_group.web_lb.id}"
    security_group_id = "${aws_security_group.grp_kube_lb.id}"
}

resource "aws_security_group_rule" "rule_kube_lb_https_web_lb" {
    type = "ingress"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    source_security_group_id = "${aws_security_group.web_lb.id}"
    security_group_id = "${aws_security_group.grp_kube_lb.id}"
}

resource "aws_security_group" "grp_kube_master" {
    name = "${var.cluster_name}-kube_master"
    description = "Security groups for allowing API access to the master nodes"
    vpc_id = "${var.vpc_id}"
}

resource "aws_security_group_rule" "rule_kube_master_ipv4" {
    type = "ingress"
    from_port = 8443
    to_port = 8443
    protocol = "tcp"
    cidr_blocks = "${var.allow_api_access_from_v4}"
    security_group_id = "${aws_security_group.grp_kube_master.id}"
}

resource "aws_security_group_rule" "rule_kube_master_from_lb" {
    type = "ingress"
    from_port = 8443
    to_port = 8443
    protocol = "tcp"
    source_security_group_id = "${aws_security_group.api_lb.id}"
    security_group_id = "${aws_security_group.grp_kube_master.id}"
}

resource "aws_security_group" "grp_weave_peers" {
    name = "${var.cluster_name}-weave_peers"
    description = "Allow Weave communication"
    vpc_id = "${var.vpc_id}"
}

resource "aws_security_group_rule" "weave_internal_peers_tcp" {
    type = "ingress"
    from_port = 6783
    to_port = 6783
    protocol = "tcp"
    self = true
    security_group_id = "${aws_security_group.grp_weave_peers.id}"
}

resource "aws_security_group_rule" "weave_internal_peers_udp" {
    type = "ingress"
    from_port = 6783
    to_port = 6784
    protocol = "udp"
    self = true
    security_group_id = "${aws_security_group.grp_weave_peers.id}"
}

resource "aws_security_group_rule" "weave_internal_peers_esp" {
    type = "ingress"
    from_port = 0
    to_port = 0
    protocol = "50"
    self = true
    security_group_id = "${aws_security_group.grp_weave_peers.id}"
}
