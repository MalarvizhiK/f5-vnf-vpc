##############################################################################
# Variable block - See each variable description
##############################################################################

##############################################################################
# ibmcloud_vnf_svc_api_key - Cloud Service apikey hosting the F5-BIGIP 
#                            image in COS. This variable is not shown to user.
#                            The value for this variable is enter at offering
#                            onbaording time.
##############################################################################
variable "ibmcloud_api_key" {
 default      = ""
 type         = "string"
 description  = "The APIKey of the IBM Cloud customer's account where VSI, custom image are created ."
}

variable "ibmcloud_vnf_svc_api_key" {
 default      = ""
 type         = "string"
 description  = "The APIKey of the IBM Cloud NFV service account that is hosting the F5-BIGIP qcow2 image file."
}

variable "ibmcloud_endpoint" {
 default      = "test.cloud.ibm.com"
 type         = "string"
 description  = "IBM Cloud URL to execute VNF creation ."
}

variable "iam_endpoint" {
 default      = "iam.test.cloud.ibm.com"
 type         = "string"
 description  = "IBM Cloud URL to create iam token ."
}

variable "rias_endpoint" {
 default      = "https://us-south-stage01-ng.iaasdev.cloud.ibm.com"
 type         = "string"
 description  = "IBM Cloud RIAS endpoint URL to fecth all custom images."
}

variable "region" {
  default     = "us-south"
  description = "The VPC Region that you want your VPC, networks and the F5 virtual server to be provisioned in. To list available regions, run `ibmcloud is regions`."
}

variable "generation" {
  default     = 2
  description = "The VPC Generation to target. Valid values are 2 or 1."
}

variable "resource_group" {
  default     = "Default"
  description = "The resource group to use. If unspecified, the account's default resource group is used."
}

##############################################################################
# Provider block - Default using logged user creds
##############################################################################
provider "ibm" {
#  ibmcloud_api_key      = "${var.ibmcloud_api_key}"
  generation            = "${var.generation}"
  region                = "${var.region}"
  resource_group        = "${var.resource_group}"
  ibmcloud_timeout      = 300
}

##############################################################################
# Provider block - Alias initialized tointeract with VNFSVC account
##############################################################################
provider "ibm" {
  alias                 = "vfnsvc"
  ibmcloud_api_key      = "${var.ibmcloud_vnf_svc_api_key}"
  generation            = "${var.generation}"
  region                = "${var.region}"
  ibmcloud_timeout      = 300
}
