variable "cluster_name" {}
variable "cluster_dns_domain" {}

variable "allow_ssh_from_v4" {
    type = "list"
    default = ["0.0.0.0/0"]
}
variable "allow_lb_from_v4" {
    type = "list"
    default = ["0.0.0.0/0"]
}
variable "allow_api_access_from_v4" {
    type = "list"
    default = ["0.0.0.0/0"]
}

variable "ssh_public_key" { default = "~/.ssh/id_rsa.pub" }

variable "master_count" { default = 3 }
variable "worker_count" { default = 4 }
