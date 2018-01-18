variable "cluster_name" {}
variable "cluster_dns_domain" {}
variable "allow_ssh_from_v4" { type = "list" }
variable "allow_lb_from_v4" { type = "list" }
variable "allow_api_access_from_v4" { type = "list" }
variable "ssh_public_key" {}
variable "master_count" {}
variable "worker_count" {}
variable "ingress_use_proxy_protocol" {}


variable "default_ingress_use_proxy_protocol" {
    type = "string"
    default = "true"
}

variable "default_ssh_key" {
    default = "~/.ssh/id_rsa.pub"
}

variable "default_acl" {
    type = "list"
    default = ["0.0.0.0/0"]
}

variable "default_master_count" {
    default = 3
}

variable "default_worker_count" {
    default = 4
}
