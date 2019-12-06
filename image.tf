##############################################################################
# This file creates custom image using F5-BIGIP qcow2 image hosted in vnfsvc COS
#  - Creates IAM Authorization Policy in vnfsvc account
#  - Creates Custom Image in User account
#
# Note: There are following gaps in ibm is provider and thus using Terraform tricks
# to overcome the gaps for the PoC sake.
# Gap1: IBM IS Provider missing resource implementation for is_image (Create, update, delete)
# Gap2: IBM IS provider missing data source to read logged user provider session info
# example: account-id
##############################################################################

# =============================================================================
# Hack: parse out the user account from the vpc resource crn
# Fix: Get data_source_ibm_iam_target added that would provide information
# about user from provider session
# =============================================================================
locals {
  user_acct_id = "${substr(element(split("a/", data.ibm_is_vpc.f5_vpc.resource_crn), 1),0,32)}"
}

##############################################################################
# Create IAM Authorization Policy for user to able to create custom image
# pointing to COS object url hosted in vnfsvc account.
##############################################################################
resource "ibm_iam_authorization_policy" "authorize_image" {
  depends_on                    = ["data.ibm_is_vpc.f5_vpc"]
  provider                      = "ibm.vfnsvc"
  source_service_account        = "${local.user_acct_id}"
  source_service_name           = "is"
  source_resource_type          = "image"
  target_service_name           = "cloud-object-storage"
  target_resource_type          = "bucket"
  roles                         = ["Reader"]
  target_resource_instance_id   = "${var.vnf_f5bigip_cos_instance_id}"
}

##############################################################################
# Read Custom Image using the image name and visibility
##############################################################################
data "ibm_is_image" "f5_custom_image" {
  depends_on  = ["data.external.create_image_hack"]
  name        = "${var.f5_image_name}"
  visibility  = "private"
}

##############################################################################
# Create Custom Image
# Hack: Given ibm provider is missing ibm_is_image resource we using
# external data provider tricks and provisining the resource using bash script.
##############################################################################
data "external" "create_image_hack" {
  depends_on  = ["ibm_iam_authorization_policy.authorize_image"]
  program     = ["bash", "${path.module}/scripts/create-image-hack.sh"]

  query = {
    ibmcloud_endpoint         = "${var.ibmcloud_endpoint}"
    ibmcloud_api_key          = "${var.ibmcloud_api_key}"
    generation                = "${var.generation}"
    region                    = "${data.ibm_is_region.region.name}"
    resource_group_id         = "${data.ibm_resource_group.rg.id}"
    f5_image_name             = "${var.f5_image_name}"
    vnf_f5bigip_cos_image_url = "${var.vnf_f5bigip_cos_image_url}"
 }
}

# resource "null_resource" "null_custom_image" {
#   # provisioner "local-exec" {
#   #   command = "${path.module}/scripts/create-image-hack.sh"
#   #   environment = {
#   #     ibmcloud_api_key = "${var.ibmcloud_api_key}"
#   #     generation = "${var.generation}"
#   #     region = "${var.region}"
#   #     resource_group_id = "${data.ibm_resource_group.rg.id}"
#   #     f5_image_name = "${var.f5_image_name}"
#   #     vnf_f5bigip_cos_image_url = "${var.vnf_f5bigip_cos_image_url}"
#   #   }
#   # }
#   # provisioner "local-exec" {
#   #   when        = "destroy"
#   #   command = <<EOT
#   #     ibmcloud plugin install vpc-infrastructure -f
#   #     ibmcloud login --apikey ${var.ibmcloud_api_key} -r "${var.region}" -g "${var.resource_group}"
#   #     ibmcloud is target --gen ${var.generation}
#   #     ibmcloud is image-delete "${data.external.create_image_hack.result.id}" -f
#   #   EOT
#   # }
# }
