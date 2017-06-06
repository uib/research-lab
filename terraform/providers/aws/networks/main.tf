# Networks

variable "cluster_name" {}
variable "cidr" { default = "10.2.0.0/16" }

data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
    cidr_block = "${var.cidr}"
    tags {
        Name = "${var.cluster_name}"
        prosjekt = "researchlab"
    }
}

resource "aws_subnet" "main" {
    count = "${length("${data.aws_availability_zones.available.names}")}"
    cidr_block = "${cidrsubnet("${aws_vpc.main.cidr_block}", 8, "${count.index}")}"
    vpc_id = "${aws_vpc.main.id}"
    availability_zone = "${data.aws_availability_zones.available.names["${count.index}"]}"
    tags {
        Name = "${var.cluster_name}-${data.aws_availability_zones.available.names["${count.index}"]}"
        prosjekt = "researchlab"
    }
}

resource "aws_internet_gateway" "gw" {
    vpc_id = "${aws_vpc.main.id}"

    tags {
        prosjekt = "researchlab"
    }
}

resource "aws_route" "default" {
    route_table_id = "${aws_vpc.main.main_route_table_id}"
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
}
