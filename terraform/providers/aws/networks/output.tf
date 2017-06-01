output "id" {
    value = "${aws_vpc.main.id}"
}

output "subnets" {
    value = "${aws_subnet.main.*.id}"
}

output "security_group_default" {
    value = "${aws_vpc.main.default_security_group_id}"
}
