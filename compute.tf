##############################################################################
# This file creates the compute instances for the solution.
# - Virtual Server using F5-BIGIP custom image
# - Two virtual servers initialized with nginx to demo Load Balancing using F5-BIGIP
##############################################################################

##############################################################################
# Read/validate sshkey
##############################################################################
data "ibm_is_ssh_key" "f5_ssh_pub_key" {
  name = "${var.ssh_key_name}"
}

##############################################################################
# Read/validate vsi profile
##############################################################################
data "ibm_is_instance_profile" "f5_profile" {
  name = "${var.f5_profile}"
}

##############################################################################
# Create F5-BIGIP virtual server.
##############################################################################
resource "ibm_is_instance" "f5_vsi" {
  name    = "${var.f5_vsi_name}"
  image   = "${data.ibm_is_image.f5_custom_image.id}"
  profile = "${data.ibm_is_instance_profile.f5_profile.name}"

  primary_network_interface = {
    subnet = "${ibm_is_subnet.f5_subnet1.id}"
  }

  vpc  = "${data.ibm_is_vpc.f5_vpc.id}"
  zone = "${data.ibm_is_zone.zone.name}"
  keys = ["${data.ibm_is_ssh_key.f5_ssh_pub_key.id}"]
  # user_data = "$(replace(file("f5-userdata.sh"), "F5-LICENSE-REPLACEMENT", var.f5_license)"

  //User can configure timeouts
  timeouts {
    create = "10m"
    delete = "10m"
  }

  # Hack to handle some race condition; will remove it once have root caused the issues.
  provisioner "local-exec" {
    command = "sleep 30"
  }
}
