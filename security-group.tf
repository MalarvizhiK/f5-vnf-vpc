##############################################################################
# This file creates the security-rules.
##############################################################################
#FIXME - set rules on f5_sg01
resource "ibm_is_security_group" "f5_sg01" {
  name = "f5-bigip-1nic-demo-sg01"
  vpc  = "${data.ibm_is_vpc.f5_vpc.id}"
}

# resource "ibm_is_security_group_rule" "f5_egress_all" {
#   depends_on = ["ibm_is_floating_ip.f5_fip01"]
#   group      = "${ibm_is_security_group.f5_sg01.id}"
#   direction  = "outbound"
#   remote     = "0.0.0.0/0"

#   tcp = {
#     port_min = 80
#     port_max = 80
#   }
# }

resource "ibm_is_security_group_rule" "f5_sg01_rule1" {
  depends_on = ["ibm_is_floating_ip.f5_fip01"]
  group      = "${ibm_is_security_group.f5_sg01.id}"
  direction  = "inbound"
  remote     = "0.0.0.0/0"

  tcp = {
    port_min = 8443
    port_max = 8443
  }
}

resource "ibm_is_security_group_rule" "f5_sg01_rule2" {
  depends_on = ["ibm_is_floating_ip.f5_fip01"]
  group      = "${ibm_is_security_group.f5_sg01.id}"
  direction  = "inbound"
  remote     = "0.0.0.0/0"

  tcp = {
    port_min = 80
    port_max = 80
  }
}

resource "ibm_is_security_group_rule" "f5_sg01_rule3" {
  depends_on = ["ibm_is_floating_ip.f5_fip01"]
  group      = "${ibm_is_security_group.f5_sg01.id}"
  direction  = "inbound"
  remote     = "0.0.0.0/0"

  tcp = {
    port_min = 22
    port_max = 22
  }
}

resource "ibm_is_security_group_rule" "f5_sg01_icmp_rule" {
  depends_on = ["ibm_is_floating_ip.f5_fip01"]
  group      = "${ibm_is_security_group.f5_sg01.id}"
  direction  = "inbound"
  remote     = "0.0.0.0/0"

  icmp = {
    code = 0
    type = 8
  }
}

resource "ibm_is_security_group_network_interface_attachment" "f5_sgnic1" {
  security_group    = "${ibm_is_security_group.f5_sg01.id}"
  network_interface = "${ibm_is_instance.f5_vsi.primary_network_interface.0.id}"
}
