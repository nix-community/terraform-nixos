provider "aws" {
  region  = "us-east-1"
  profile = "yourprofile"
}

resource "aws_instance" "hermetic-nixos-system" {
  count         = 1
  ami           = "ami-068a62d478710462d" # NixOS 20.09 AMI

  instance_type = "t2.micro"

  key_name  = "yourkeyname"

  tags = {
    Name        = "hermetic-nixos-system-example"
    Description = "An example of a hermetic NixOS system deployed by Terraform"
  }
}

module "deploy_nixos" {
  source               = "github.com/awakesecurity/terraform-nixos//deploy_nixos?ref=c4b1ee6d24b54e92fa3439a12bce349a6805bcdd"
  nixos_config         = "${path.module}/configuration.nix"
  hermetic             = true
  target_user          = "root"
  target_host          = aws_instance.hermetic-nixos-system[0].public_ip
  ssh_private_key_file = pathexpand("~/.ssh/yourkeyname.pem")
}
