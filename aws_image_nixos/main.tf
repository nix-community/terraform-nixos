variable "release" {
  type        = "string"
  default     = "latest"
  description = "The NixOS version to use. For example, 18.09"
}

variable "region" {
  type        = "string"
  default     = ""
  description = "The region to use. If not provided, current provider's region will be used."
}

variable "type" {
  type        = "string"
  default     = "hvm-ebs"
  description = "The type of the AMI to use -- hvm-ebs, pv-ebs, or pv-s3."
}

# ---

data "aws_region" "current" {}

locals {
  key = "${var.release}.${coalesce(var.region, data.aws_region.current.name)}.${var.type}"
  ami = "${lookup(var.url_map, local.key)}"
}

# ---

output "ami" {
  description = "NixOS AMI on AWS"
  value       = "${local.ami}"
}
