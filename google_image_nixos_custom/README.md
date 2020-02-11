# google_cloud_image_nixos

This terraform module builds and publishes custom NixOS Google Cloud images.

## Runtime dependencies

Because this module uses the "external" provider it needs the following
executables to be in the path to work properly:

* bash
* nix
* `readlink -f` (busybox or coreutils)

## Known limitations

NixOS images are built at Terraform plan time. This can make the plan quite
slow.

Building the image doesn't yield any output, unless the build is interrupted or
failed.

When a new image is published, the old-one gets removed. This potentially
introduces a race-condition where other targets are trying to create new
instances with the old image. To reduce the race window, `create_before_destroy` is being used. See
https://github.com/hashicorp/terraform/issues/15485 for related discussions.

Only x86_64-linux is currently supported.

<!-- terraform-docs-start -->
## Providers

| Name | Version |
|------|---------|
| external | n/a |
| google | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| NIX\_PATH | Allow to pass custom NIX\_PATH. Ignored if `-` or empty. | `string` | `"-"` | no |
| bucket\_name | Bucket where to store the image | `any` | n/a | yes |
| gcp\_project\_id | The ID of the project in which the resource belongs. If it is not provided, the provider project is used. | `string` | `""` | no |
| licenses | A list of license URIs to apply to this image. Changing this forces a new resource to be created. | `list(string)` | <pre>[<br>  "https://www.googleapis.com/compute/v1/projects/vm-options/global/licenses/enable-vmx"<br>]</pre> | no |
| nixos\_config | Path to a nixos configuration.nix file | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| NIX\_PATH | n/a |
| self\_link | n/a |

<!-- terraform-docs-end -->
