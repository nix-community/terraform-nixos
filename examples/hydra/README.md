Setup a CI on an Openstack cloud for a Nix repository in one command: `terraform apply`

Terraform will then
- upload a NixOS base image on Glance (the Openstack image service)
- boot two instances: one for Hydra, one for a Nix slave
- configure this two instances by switching them to a new configuration
- setup a declarative project (https://github.com/shlevy/declarative-hydra-example) through Hydra API.

