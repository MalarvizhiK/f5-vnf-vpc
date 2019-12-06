##############################################################################
# This file creates two compute instances that will be used by PoC to setup
# F5-BIGIP loadbalancer. Each of the backend server will be enabled with nginx
# and a customize welcome page via cloud-init.
# - Two Virtual Server using ubuntu-18-04-amd64
##############################################################################

data "template_file" "welcom_page" {
    template = "${file("${path.module}/templates/index.nginx-debian.html.tpl")}"
    vars = {
        server_marker = "One"
    }
}

##############################################################################
# Read Public Image using the image name and visibility
##############################################################################
data "ibm_is_image" "ubuntu_18_image" {
  name        = "ibm-ubuntu-18-04-64"
  visibility  = "public"
}

resource "ibm_is_instance" "backend_vsi" {
  count     = 2
  name      = "backend-vsi-0${count.index}"
  image     = "${data.ibm_is_image.ubuntu_18_image.id}"
  profile   = "cx2-2x4"

  primary_network_interface = {
    subnet  = "${ibm_is_subnet.f5_subnet1.id}"
  }

  vpc       = "${data.ibm_is_vpc.f5_vpc.id}"
  zone      = "${data.ibm_is_zone.zone.name}"
  keys      = ["${data.ibm_is_ssh_key.f5_ssh_pub_key.id}"]
  user_data = <<EOF
#!/bin/bash -v
apt-get update -y
apt-get install -y nginx > /tmp/nginx.log
echo "${base64encode(data.template_file.welcom_page.rendered)}" | base64 -d | sed 's/SERVER_MARKER/${count.index}/g' > /var/www/html/index.nginx-debian.html
service nginx start
EOF

  //User can configure timeouts
  timeouts {
    create = "10m"
    delete = "10m"
  }
}
