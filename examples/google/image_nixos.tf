# Here is a simple example that instantiates the google image and spins up an
# instance

module "nixos_image_1809" {
  source        = "../../google_image_nixos"
  nixos_version = "18.09"
}

// This instance is not very useful since it doesn't contain any
// configuration. This could be fixed by passing a user metadata script.
resource "google_compute_instance" "image-nixos" {
  name         = "image-nixos"
  machine_type = "n1-standard-1"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "${module.nixos_image_1809.self_link}"
    }
  }

  network_interface {
    network = "default"
  }
}
