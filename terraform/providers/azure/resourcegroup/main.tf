variable "region" {}
variable "cluster_name" {}

variable "tag_environment" {}
variable "tag_activity" {}

# Create a resource group
resource "azurerm_resource_group" "researchlab" {
    name     = "uhsky.researchlab.${var.cluster_name}"
    location = "${var.region}"

    tags {
      environment = "${var.tag_environment}",
      uninett_activity = "${var.tag_activity}"
    }
}
