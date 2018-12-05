# create a random ID for the bucket
resource "random_id" "bucket" {
  byte_length = 8
}

# create a bucket to upload the image into
resource "google_storage_bucket" "nixos-images" {
  name     = "nixos-images-${random_id.bucket.hex}"
  location = "EU"
}

# create a custom nixos images based on the nix code
module "nixos_image_custom" {
  source       = "../../google_image_nixos_custom"
  bucket_name  = "${google_storage_bucket.nixos-images.name}"
  nixos_config = "${path.module}/image_nixos_custom.nix"
}

# spin up the instance
resource "google_compute_instance" "image-nixos-custom" {
  name         = "image-nixos-custom"
  machine_type = "n1-standard-1"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "${module.nixos_image_custom.self_link}"
      size  = "20"
    }
  }

  network_interface {
    network = "default"

    // Give it a public IP
    access_config {}
  }

  lifecycle {
    // No need to re-deploy the machine if the image changed
    // NixOS is already immutable
    ignore_changes = ["boot_disk"]
  }
}

module "deploy_nixos" {
  source       = "../../deploy_nixos"
  nixos_config = "${path.module}/image_nixos_custom.nix"
  target_host  = "${google_compute_instance.image-nixos-custom.network_interface.0.network_ip}"

  triggers = {
    // Also re-deploy whenever the VM is re-created
    instance_id = "${google_compute_instance.image-nixos-custom.id}"
  }

  // Pass some secrets. See the terraform-servets-provider to handle secrets
  // in Terraform
  keys = {
    foo = "bar"
  }
}
