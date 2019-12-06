##############################################################################
# Variable block - See each variable description
##############################################################################

##############################################################################
# vnf_f5bigip_cos_instance_id - Vendor provided COS instance-id hosting 
#                               F5-BIGIP image. 
#                               The value for this variable is enter at offering
#                               onbaording time. This variable is hidden from the user.
##############################################################################
variable "vnf_f5bigip_cos_instance_id" {
  default     = ""
  description = "The COS instance-id hosting the F5-BIGIP qcow2 image."
}

##############################################################################
# vnf_f5bigip_cos_image_url - Vendor provided F5-BIGIP image COS url
#                             The value for this variable is enter at offering
#                             onbaording time.This variable is hidden from the user.
##############################################################################
variable "vnf_f5bigip_cos_image_url" {
  default     = ""
  description = "The COS image object url for F5-BIGIP qcow2 image."
}

##############################################################################
# zone - VPC zone where resources are to be provisioned.
##############################################################################
variable "zone" {
  default     = "us-south-1"
  description = "The VPC Zone that you want your VPC networks and virtual servers to be provisioned in. To list available zones, run `ibmcloud is zones`."
}

##############################################################################
# vpc_name - VPC where resources are to be provisioned.
##############################################################################
variable "vpc_name" {
  default     = "f5-1arm-vpc"
  description = "The name of your VPC where F5-BIGIP VSI is to be provisioned."
}

##############################################################################
# ssh_key_name - The name of the public SSH key to be used when provisining F5-BIGIP VSI.
##############################################################################
variable "ssh_key_name" {
  default     = "f5-1arm-sshkey"
  description = "The name of the public SSH key to be used when provisining F5-BIGIP VSI."
}

##############################################################################
# f5_image_name - The name of the F5-BIGIP custom image to be provisioned in your IBM Cloud account.
##############################################################################
variable "f5_image_name" {
  default     = "f5-bigip-15-0-1-0-0-11"
  description = "The name of the F5-BIGIP custom image to be provisioned in your IBM Cloud account."
}

##############################################################################
# f5_image_name - The name of your F5-BIGIP Virtual Server to be provisioned
##############################################################################
variable "f5_vsi_name" {
  default     = "f5-1arm-vsi01"
  description = "The name of your F5-BIGIP Virtual Server to be provisioned."
}

##############################################################################
# f5_profile - The profile of compute CPU and memory resources to be used when provisioning F5-BIGIP VSI.
##############################################################################
variable "f5_profile" {
  default     = "bx2-2x8"
  description = "The profile of compute CPU and memory resources to be used when provisioning F5-BIGIP VSI. To list available profiles, run `ibmcloud is instance-profiles`."
}

variable "f5_license" {
  default     = ""
  description = "Optional. The BYOL license key that you want your F5 virtual server in a VPC to be used by registration flow during cloud-init."
}

variable "ibmcloud_endpoint" {
  default     = "cloud.ibm.com"
  description = "[Temp Hack] Optional. The IBM Cloud endpoint used by create_image_hack script."
}
