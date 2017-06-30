output "ssh" {
    value = "${aws_security_group.grp_ssh_access.id}"
}

output "lb" {
    value = "${aws_security_group.grp_kube_lb.id}"
}

output "master" {
    value = "${aws_security_group.grp_kube_master.id}"
}

output "api_lb" {
    value = "${aws_security_group.api_lb.id}"
}

output "web_lb" {
    value = "${aws_security_group.web_lb.id}"
}

output "weave" {
    value = "${aws_security_group.grp_weave_peers.id}"
}
