variable "version" {
  type        = "string"
  default     = "latest"
  description = "The NixOS version to use. Eg: 18.09"
}

variable "gcp_project_id" {
  type        = "string"
  default     = ""
  description = "The ID of the project in which the resource belongs. If it is not provided, the provider project is used."
}

variable "licenses" {
  type = "list"

  default = [
    "https://www.googleapis.com/compute/v1/projects/vm-options/global/licenses/enable-vmx",
  ]

  description = "A list of license URIs to apply to this image. Changing this forces a new resource to be created."
}

# ---

locals {
  image_url = "${lookup(var.url_map, var.version)}"

  # Example: nixos-image-18-09-1228-a4c4cbb613c-x86-64-linux
  #
  # Remove a few things so that it matches the required regexp for image names
  #   (?:[a-z](?:[-a-z0-9]{0,61}[a-z0-9])?)
  image_name = "${replace(replace(basename(local.image_url), ".raw.tar.gz", ""), "/[._]+/", "-")}"
}

resource "google_compute_image" "nixos" {
  name        = "${local.image_name}"
  description = "NixOS ${var.version}"
  family      = "nixos"
  project     = "${var.gcp_project_id}"
  licenses    = ["${var.licenses}"]

  raw_disk {
    source = "${local.image_url}"
  }
}

# ---

output "self_link" {
  description = "Link to the NixOS Compute Image"
  value       = "${google_compute_image.nixos.self_link}"
}
