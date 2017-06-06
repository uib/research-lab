variable "cluster_name" {}
variable "subnets" { type = "list" }
variable "sec_group_api_lb" { type = "list" }
variable "sec_group_web_lb" { type = "list" }
variable "masters" { type = "list" }
variable "workers" { type = "list" }

resource "aws_elb" "api_lb" {
    name = "${var.cluster_name}-api-lb"
    instances = [ "${var.masters}" ]
    cross_zone_load_balancing = true
    subnets = [ "${var.subnets}" ]
    security_groups = [ "${var.sec_group_api_lb}" ]

    health_check {
        healthy_threshold = 3
        unhealthy_threshold = 2
        timeout = 5
        target = "TCP:8443"
        interval = 10
    }

    listener {
        instance_port = 8443
        instance_protocol = "TCP"
        lb_port = 443
        lb_protocol = "TCP"
    }

}

resource "aws_elb" "web_lb" {
    name = "${var.cluster_name}-web-lb"
    instances = [ "${slice(var.workers, 0, 3)}" ]
    cross_zone_load_balancing = true
    subnets = [ "${var.subnets}" ]
    security_groups = [ "${var.sec_group_web_lb}" ]

    health_check {
        healthy_threshold = 3
        unhealthy_threshold = 2
        timeout = 5
        target = "TCP:80"
        interval = 10
    }

    listener {
        instance_port = 80
        instance_protocol = "TCP"
        lb_port = 80
        lb_protocol = "TCP"
    }

    listener {
        instance_port = 443
        instance_protocol = "TCP"
        lb_port = 443
        lb_protocol = "TCP"
    }

}

resource "aws_proxy_protocol_policy" "web_lb_proxy_protocol" {
    load_balancer = "${aws_elb.web_lb.name}"
    instance_ports = [ "80", "443" ]
}
