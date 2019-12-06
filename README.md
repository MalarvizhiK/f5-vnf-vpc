# F5-BIGIP Virtual Server for Virtual Private Cloud using Custom Image

With this template, you can use IBM Cloud Schematics to create F5-BIGIP virtual server using custom image from your IBM Cloud account. Schematics uses [Terraform](https://www.terraform.io/) as the infrastructure-as-code engine. With this template, you can create and manage infrastructure as a single unit as follows. For more information about how to use this template, see the [IBM Cloud Schematics documentation](https://cloud.ibm.com/docs/schematics).

**Prerequisites**:
* 1. Must have VPC.
* 2. The Given VPC must have atleast one subnet IP address unassigned, that will be used by F5-BIGIP VSI.
* 3. Must have atleast one available Floating/Public IP address for reservation, that will be attach to the F5-BIGIP VSI Primary Interface.
* 4. F5-BIGIP Custom Image (BIGIP-15.0.1-0.0.11.qcow2) must be in a COS location.

**Must have IBM IS Terraform Provider fixes**:
* Provide `resource for ibm_is_image` - IS Image create, update, delete, exist.

## Costs

When you apply template, the infrastructure resources that you create incur charges as follows. To clean up the resources, you can [delete your Schematics workspace or your instance](https://cloud.ibm.com/docs/schematics?topic=schematics-manage-lifecycle#destroy-resources). Removing the workspace or the instance cannot be undone. Make sure that you back up any data that you must keep before you start the deletion process.

* **VPC**: VPC charges are incurred for the infrastructure resources within the VPC, as well as network traffic for internet data transfer. For more information, see [Pricing for VPC](https://cloud.ibm.com/docs/vpc-on-classic?topic=vpc-on-classic-pricing-for-vpc).
* **VPC Custom Image Instances**: You specify, how many VSI to provision in each VPC. The price for your virtual server instances depends on the flavor of the instances, how many you provision, and how long the instances are run. For more information, see [Pricing for Virtual Servers for VPC](https://cloud.ibm.com/docs/infrastructure/vpc-on-classic?topic=vpc-on-classic-pricing-for-vpc#pricing-for-virtual-servers-for-vpc).

## Dependencies

Before you can apply the template in IBM Cloud, complete the following steps.

1.  Make sure that you have the following permissions in IBM Cloud Identity and Access Management:
    * **Manager** service access role for IBM Cloud Schematics
    * **Operator** platform role for VPC Infrastructure
2.  Ensure that, given VPC and SSHKey already exists in your account - Otherwise, creation will be failed.
3.  Ensure that, given VPC has subnet - Otherwise, create will be failed.
4.  Ensure that, floating/public IP is unreserved for F5-BIGIP VSI - Otherwise, creation will be failed.

## Configuring your deployment values

When you select the [`vnf-f5-vpc`template](https://cloud.ibm.com/catalog/content/vnf-f5-vpc) from the IBM Cloud catalog, you set up your deployment variables from the **Create** page. When you apply the template, IBM Cloud Schematics provisions the resources according to the values that you specify for these variables.

### Required values
Fill in the following values, based on the steps that you completed before you began.

|Variable Name|Description|
|-------------|-----------|
|`ibmcloud_vnf_svc_api_key`|The APIKey of the IBM Cloud NFV service account that is hosting the F5-BIGIP qcow2 image file.|`None`|
|`generation`|The VPC Generation to target. Valid values are 2 or 1..|`2`|
|`region`|The VPC Region that you want your VPC to be provisioned. To list available zones, run `ibmcloud is regions`.|`us-south`|
|`zone`|The VPC Zone that you want your VPC virtual servers to be provisioned. To list available zones, run `ibmcloud is zones`.|`us-south-1`|
|`resource_group`|The resource group to use. If unspecified, the account's default resource group is used. To list available resource groups, run `ibmcloud resource groups`.|`Default`|
|`vpc_name`|The name of your VPC in which F5-BIGIP VSI is to be provisioned.|`None`|
|`ssh_key_name`|The name of your public SSH key to be used for F5-BIGIP VSI. Follow [Public SSH Key Doc](https://cloud.ibm.com/docs/vpc-on-classic-vsi?topic=vpc-on-classic-vsi-ssh-keys) for creating and managing ssh key.|`None`|
|`f5_image_name`|The name of the F5 Custom Image to be provisioned in your IBM Cloud account.|`f5-bigip-15-0-1-0-0-11`|
|`f5_vsi_name`|The name of your F5 Virtual Server to be provisioned.|`f5-1arm-vsi`|
|`f5_profile`|Enter the profile of compute CPU and memory resources that you want your F5-BIGIP virtual servers to have. To list available profiles, run `ibmcloud is instance-profiles`.|`bx2-2x8`|
|`f5_license`|Optional: The BYOL license key that you want your F5 virtual server in a VPC to be used by registration flow during cloud-init.|`None`|
|`vnf_f5bigip_cos_instance_id`|The COS instance-id hosting the F5-BIGIP qcow2 image.|`NA`|
|`vnf_f5bigip_cos_image_url`|The COS image object url for F5-BIGIP qcow2 image.|`NA`|

## Outputs
After you apply the template your VPC resources are successfully provisioned in IBM Cloud, you can review information such as the virtual server IP addresses and VPC identifiers in the Schematics log files, in the `Terraform SHOW` section.

|Variable Name|Description|Default Value|
|-------------|-----------|-------------|
|f5_admin_portal|Web url to interact with F5-BIGIP admin portal.|`None`|

## Note
1. If any failure, while F5-BIGIP VSI creation, make sure that, the created resources must be destroyed before creating the same again. To destroy resources go to Schematics -> Workspaces -> [Your Workspace] -> Actions -> Destroy Resources
2. The BYOI image download may take a while. Timeout has been set 30 Minutes to avoid unnecessary problems.
3. Should not modify or delete subnets and floating/public IPs. It may create unnecessary problems, while destroying resources using schematic.
