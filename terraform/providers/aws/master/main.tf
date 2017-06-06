variable "instance_type" {}
variable "image" {}
variable "count" {}
variable "cluster_name" {}
variable "key_name" {}
variable "subnets" { type = "list" }
variable "sec_groups" { type = "list" }

# Master nodes
resource "aws_instance" "master" {
    count = "${var.count}"
    ami = "${var.image}"
    instance_type = "${var.instance_type}"
    key_name = "${var.key_name}"
    subnet_id = "${var.subnets[count.index % length(var.subnets)]}"

    vpc_security_group_ids = ["${var.sec_groups}"]
    user_data = "#cloud-config\nhostname: ${var.cluster_name}-master-${count.index}\n"

    tags {
        Name = "${var.cluster_name}-master-${count.index}"
    }
}

resource "aws_eip" "master" {
    count = "${var.count}"
    instance = "${aws_instance.master.*.id[count.index]}"
}

data "template_file" "masters_ansible" {
    template = "$${name} ansible_host=$${ip} public_ip=$${ip}"
    count = "${var.count}"
    vars {
        name  = "${var.cluster_name}-master-${count.index}"
        ip = "${aws_eip.master.*.public_ip[count.index]}"
    }
}
