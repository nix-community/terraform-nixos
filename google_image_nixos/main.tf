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

# ---

locals {
  image_url  = "${lookup(var.url_map, var.version)}"
  image_name = "${replace(replace(basename(local.image_url), ".raw.tar.gz", ""), "/[._]/", "-")}"
}

resource "google_compute_image" "nixos" {
  name        = "${local.image_name}"
  description = "NixOS ${var.version}"
  family      = "nixos"
  project     = "${var.gcp_project_id}"

  raw_disk {
    source = "${local.image_url}"
  }
}

# ---

output "self_link" {
  description = "Link to the NixOS Compute Image"
  value       = "${google_compute_image.nixos.self_link}"
}
