# `google_image_nixos`

This terraform module creates a new image in the Google Cloud project using a
public tarballs of a NixOS release. Those tarballs are released by the NixOS
project.

Since image names are unique, only one instance per version of the module is
supported per Google Cloud project.

## Example

```hcl
module "nixos_image_1809" {
  source = "github.com/zimbatm/terraform-nix/google_image_nixos"
  release = "18.09"
}

resource "google_compute_instance" "example" {
  name         = "example"
  machine_type = "n1-standard-1"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "${module.nixos_image_1809.self_link}"
    }
  }

  network_interface {
    network       = "default"
  }
}
```

### Default configuration.nix

A new configuration.nix can be passed trough the userdata. Here is the default
configuration to expand upon:

```nix
{ modulesPath, ... }:
{
  imports = [
    "${toString modulesPath}/virtualisation/google-compute-image.nix"
  ];
}
```

## New NixOS releases

Run the `./update-url-map` script to fetch new image releases. Please submit a
PR as well!

<!-- terraform-docs-start -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| gcp\_project\_id | The ID of the project in which the resource belongs. If it is not provided, the provider project is used. | string | `` | no |
| url\_map | A map of release series to actual releases | map | `<map>` | no |
| version | The NixOS version to use. Eg: 18.09 | string | `latest` | no |

## Outputs

| Name | Description |
|------|-------------|
| self\_link | Link to the NixOS Compute Image |

<!-- terraform-docs-end -->
