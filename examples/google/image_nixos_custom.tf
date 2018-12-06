# create a random ID for the bucket
resource "random_id" "bucket" {
  byte_length = 8
}

# create a bucket to upload the image into
resource "google_storage_bucket" "nixos-images" {
  name     = "nixos-images-${random_id.bucket.hex}"
  location = "EU"
}

# create a custom nixos base image the deployer can SSH into
#
# this could also include much more configuration and be used to feed the
# auto-scaler with system images
module "nixos_image_custom" {
  source      = "../../google_image_nixos_custom"
  bucket_name = "${google_storage_bucket.nixos-images.name}"

  nixos_config = "${path.module}/image_nixos_custom.nix"
}
