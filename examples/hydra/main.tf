output "hydra_url" {
  description = "Deployed Hydra URL"
  value       = "http://${openstack_networking_floatingip_v2.hydra.address}:3000"
}

module "deploy_nixos_hydra" {
  source = "../../deploy_nixos"
  NIX_PATH = "nixpkgs=channel:nixos-18.09"
  nixos_config = <<EOF
    { lib, ...}:
    {
      imports = [ ./configuration.nix ];
       nix.buildMachines = [{
        hostName = "${openstack_networking_port_v2.slave.all_fixed_ips.0}";
        sshUser = "root";
        sshKey = "/var/keys/hydra_private_keys";
        systems = [ "x86_64-linux" "builtin" ];
        maxJobs = 1;
      }];
    }
    EOF
  target_user = "root"
  target_host = "${openstack_networking_floatingip_v2.hydra.address}"
  triggers = {
    instance_id = "${openstack_compute_instance_v2.hydra.id}"
  }

  keys = {
    hydra_private_key = "${openstack_compute_keypair_v2.hydra.private_key}"
  }
}

module "deploy_nixos_slave" {
  source = "../../deploy_nixos"
  NIX_PATH = "nixpkgs=channel:nixos-18.09"
  nixos_config = <<EOF
    { lib, ...}:
    {
      imports = [ "/home/lewo/repos/nixpkgs/nixos/maintainers/scripts/openstack/openstack-image.nix" ];
      users.extraUsers.root.openssh.authorizedKeys.keys = [ "${openstack_compute_keypair_v2.hydra.public_key}" ];
    }
    EOF
  target_user = "root"
  target_host = "${openstack_networking_floatingip_v2.slave.address}"
  triggers = {
    instance_id = "${openstack_compute_instance_v2.slave.id}"
  }
  keys = {
    hydra_private_key = "${openstack_compute_keypair_v2.hydra.public_key}"
  }
}

# This can be pretty long since the image is first downloaded locally
# and then uploaded to Glance.
resource "openstack_images_image_v2" "nixos" {
  name   = "nixos-master"
  # FIXME: Update this with an image coming from the nixos.org/nixos/download page :/
  image_source_url = "https://cloud.abesis.fr/s/KrfPrQrbd5yW2tz/download"
  container_format = "bare"
  disk_format = "qcow2"
}

resource "openstack_compute_keypair_v2" "hydra" {
  name = "hydra"
}

resource "openstack_networking_network_v2" "nixos" {
  name = "nixos"
  admin_state_up = "true"
}

resource "openstack_compute_secgroup_v2" "ssh" {
  name = "ssh"
  description = "ssh"
  rule {
    from_port = 22
    to_port = 22
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
}

resource "openstack_compute_secgroup_v2" "hydra" {
  name = "hydra"
  description = "hydra"
  rule {
    from_port = 3000
    to_port = 3000
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
}

resource "openstack_networking_subnet_v2" "nixos" {
  name = "nixos"
  network_id = "${openstack_networking_network_v2.nixos.id}"
  cidr = "192.168.1.0/24"
  ip_version = 4
  enable_dhcp = true
}

resource "openstack_networking_port_v2" "hydra" {
  network_id = "${openstack_networking_network_v2.nixos.id}"
  admin_state_up = "true"
  security_group_ids = ["${openstack_compute_secgroup_v2.ssh.id}", "${openstack_compute_secgroup_v2.hydra.id}"]
  fixed_ip {
    subnet_id = "${openstack_networking_subnet_v2.nixos.id}"
  }
}

resource "openstack_networking_port_v2" "slave" {
  network_id = "${openstack_networking_network_v2.nixos.id}"
  admin_state_up = "true"
  security_group_ids = ["${openstack_compute_secgroup_v2.ssh.id}"]
  fixed_ip {
    subnet_id = "${openstack_networking_subnet_v2.nixos.id}"
  }
}

resource "openstack_networking_floatingip_v2" "hydra" {
  pool = "public"
  port_id = "${openstack_networking_port_v2.hydra.id}"
}

resource "openstack_networking_floatingip_v2" "slave" {
  pool = "public"
  port_id = "${openstack_networking_port_v2.slave.id}"
}

resource "openstack_compute_instance_v2" "hydra" {
  name = "hydra"
  image_name = "${openstack_images_image_v2.nixos.name}"
  flavor_name = "s1.cw.small-1"
  network {
    port = "${openstack_networking_port_v2.hydra.id}"
  }
  key_pair = "rj45"
}

resource "openstack_compute_instance_v2" "slave" {
  name = "slave"
  image_name = "${openstack_images_image_v2.nixos.name}"
  flavor_name = "s1.cw.small-1"
  network {
    port = "${openstack_networking_port_v2.slave.id}"
  }
  key_pair = "rj45"
}
