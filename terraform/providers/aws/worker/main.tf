variable "instance_type" {}
variable "image" {}
variable "count" {}
variable "cluster_name" {}
variable "key_name" {}
variable "subnets" { type = "list" }
variable "sec_groups" { type = "list" }

# Worker nodes
resource "aws_instance" "worker" {
    count = "${var.count}"
    ami = "${var.image}"
    instance_type = "${var.instance_type}"
    key_name = "${var.key_name}"
    subnet_id = "${var.subnets[count.index % length(var.subnets)]}"

    vpc_security_group_ids = ["${var.sec_groups}"]
    user_data = "#cloud-config\nhostname: ${var.cluster_name}-worker-${count.index}\n"

    tags {
        Name = "${var.cluster_name}-worker-${count.index}"
    }
}

resource "aws_eip" "worker" {
    count = "${var.count}"
    instance = "${aws_instance.worker.*.id[count.index]}"
}

data "template_file" "workers_ansible" {
    template = "$${name} ansible_host=$${ip} lb=$${lb_flag}"
    count = "${var.count}"
    vars {
        name  = "${var.cluster_name}-worker-${count.index}"
        ip = "${aws_eip.worker.*.public_ip[count.index]}"
        lb_flag = "${count.index < 3 ? "true" : "false"}"
    }
}
