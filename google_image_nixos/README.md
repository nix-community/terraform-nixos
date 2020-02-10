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
## Providers

| Name | Version |
|------|---------|
| google | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| gcp\_project\_id | The ID of the project in which the resource belongs. If it is not provided, the provider project is used. | `string` | `""` | no |
| licenses | A list of license URIs to apply to this image. Changing this forces a new resource to be created. | `list(string)` | <pre>[<br>  "https://www.googleapis.com/compute/v1/projects/vm-options/global/licenses/enable-vmx"<br>]</pre> | no |
| nixos\_version | The NixOS version to use. Eg: 18.09 | `string` | `"latest"` | no |
| url\_map | A map of release series to actual releases | `map(string)` | <pre>{<br>  "14.12": "https://nixos-cloud-images.storage.googleapis.com/nixos-14.12.471.1f09b77-x86_64-linux.raw.tar.gz",<br>  "15.09": "https://nixos-cloud-images.storage.googleapis.com/nixos-15.09.425.7870f20-x86_64-linux.raw.tar.gz",<br>  "16.03": "https://nixos-cloud-images.storage.googleapis.com/nixos-image-16.03.847.8688c17-x86_64-linux.raw.tar.gz",<br>  "17.03": "https://nixos-cloud-images.storage.googleapis.com/nixos-image-17.03.1082.4aab5c5798-x86_64-linux.raw.tar.gz",<br>  "18.03": "https://nixos-cloud-images.storage.googleapis.com/nixos-image-18.03.132536.fdb5ba4cdf9-x86_64-linux.raw.tar.gz",<br>  "18.09": "https://nixos-cloud-images.storage.googleapis.com/nixos-image-18.09.1228.a4c4cbb613c-x86_64-linux.raw.tar.gz",<br>  "latest": "https://nixos-cloud-images.storage.googleapis.com/nixos-image-18.09.1228.a4c4cbb613c-x86_64-linux.raw.tar.gz"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| self\_link | Link to the NixOS Compute Image |

<!-- terraform-docs-end -->
