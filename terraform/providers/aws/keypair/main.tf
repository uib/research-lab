variable "name" {}
variable "pubkey_file" {}

resource "aws_key_pair" "keypair" {
    key_name = "${var.name}"
    public_key = "${file(var.pubkey_file)}"
}
