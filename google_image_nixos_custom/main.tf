variable "bucket_name" {
  description = "Bucket where to store the image"
}

variable "nixos_config" {
  description = "Path to a nixos configuration.nix file"
}

variable "NIX_PATH" {
  type        = string
  description = "Allow to pass custom NIX_PATH. Ignored if `-` or empty."
  default     = "-"
}

variable "gcp_project_id" {
  type        = string
  default     = ""
  description = "The ID of the project in which the resource belongs. If it is not provided, the provider project is used."
}

variable "licenses" {
  type = list(string)

  default = [
    "https://www.googleapis.com/compute/v1/projects/vm-options/global/licenses/enable-vmx",
  ]

  description = "A list of license URIs to apply to this image. Changing this forces a new resource to be created."
}

# ----------------------------------------------------

data "external" "nix_build" {
  program = concat(
    ["${path.module}/nixos-build.sh", var.nixos_config],
    var.NIX_PATH == "" || var.NIX_PATH == "-" ? [] : ["-I", var.NIX_PATH]
  )
}

locals {
  out_path   = data.external.nix_build.result.out_path
  image_path = data.external.nix_build.result.image_path

  # 3x2d4rdm9kjzk9d9sz87rmhzvcphs23v
  out_hash = element(split("-", basename(local.out_path)), 0)

  # Example: 3x2d4rdm9kjzk9d9sz87rmhzvcphs23v-19-03pre-git-x86-64-linux
  #
  # Remove a few things so that it matches the required regexp for image names
  #   (?:[a-z](?:[-a-z0-9]{0,61}[a-z0-9])?)
  image_name = "x${substr(local.out_hash, 0, 12)}-${replace(
    replace(
      basename(local.image_path),
      "/\\.raw\\.tar\\.gz|nixos-image-/",
      "",
    ),
    "/[._]+/",
    "-",
  )}"

  # 3x2d4rdm9kjzk9d9sz87rmhzvcphs23v-nixos-image-19.03pre-git-x86_64-linux.raw.tar.gz
  image_filename = "${local.out_hash}-${basename(local.image_path)}"
}

resource "google_storage_bucket_object" "nixos" {
  name         = "images/${local.image_filename}"
  source       = local.image_path
  bucket       = var.bucket_name
  content_type = "application/tar+gzip"

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_image" "nixos" {
  name     = local.image_name
  family   = "nixos"
  project  = var.gcp_project_id
  licenses = var.licenses

  raw_disk {
    source = "https://${var.bucket_name}.storage.googleapis.com/${google_storage_bucket_object.nixos.name}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

output "self_link" {
  value = google_compute_image.nixos.self_link
}

