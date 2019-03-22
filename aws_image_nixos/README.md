# AWS Collection of NixOS AMIs

This terraform module provides links to official NixOS AMIs on AWS. The AMIs are
released by the NixOS project.

Since image names are unique, only one instance per version of the module is
supported.

## Example

    locals {
      region = "us-west-2"
    }

    module "nixos_image_1809" {
      source  = "path/to/aws_image_nixos"
      release = "18.09"
      region  = "${local.region}"
    }

    resource "aws_instance" "example" {
      ami           = "${module.nixos_image_1809.self_link}"
      instance_type = "t2.micro"
      region        = "${local.region}"

      ...
    }

## New NixOS releases

Run the `./update-url-map` script to fetch new image releases. 

<!-- terraform-docs-start -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| region | The region to use. If not provided, current provider's region will be used. | string | `` | no |
| release | The NixOS version to use. For example, 18.09 | string | `latest` | no |
| type | The type of the AMI to use -- hvm-ebs, pv-ebs, or pv-s3. | string | `hvm-ebs` | no |
| url\_map | A map of release series to actual releases | map | `<map>` | no |

## Outputs

| Name | Description |
|------|-------------|
| ami | NixOS AMI on AWS |

