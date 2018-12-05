# `google_image_nixos_custom`

This terraform module builds and publishes custom NixOS Google Cloud images.

## Runtime dependencies

Because this module uses the "external" provider it needs the following
executables to be in the path to work properly:

* nix-shell

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
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| bucket\_name | Bucket where to store the image | string | - | yes |
| gcp\_project\_id | The ID of the project in which the resource belongs. If it is not provided, the provider project is used. | string | `` | no |
| nixos\_config | Path to a nixos configuration.nix file | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| self\_link | - |

<!-- terraform-docs-end -->
