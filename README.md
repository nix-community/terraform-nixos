# Terraform and Nix integration

[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)

This repository contains a set of Terraform Modules designed to deploy NixOS
machines. These modules are designed to work together and support different
deployment scenarios.

## What is Terraform?

[Terraform][terraform] is a tool that allows to declare infrastructures as
code.

## What is Nix, nixpkgs and NixOS?

[Nix][nix] is a build system and package manager that allows to manage whole
system configurations as code. nixpkgs is a set of 20k+ packages built with
Nix. NixOS is a Linux distribution built on top of nixpkgs.

## What is a Terraform Module?

A Terraform Module refers to a self-contained packages of Terraform
configurations that are managed as a group. This repo contains a collection of
Terraform Modules which can be composed together to create useful
infrastructure patterns. 

## Terraform + Nix vs NixOps

NixOps is a great tool for personal deployments. It handles a lot of things
like cloud resource creation, machine NixOS bootstrapping and deployment.

The difficulty is when the cloud resources are not supported by NixOps. It
takes a lot of work to map all the cloud APIs. Compared to NixOps, Terraform
has become an industry standard and has thousands of people contributing new
cloud API mapping all the time.

Another issue is when sharing the configuration as code with multiple
developers. Both NixOps and Terraform maintain a state file of "known applied"
configuration. Unlike NixOps, Terraform provides facilities to sync and lock
the state file so it's available by other users.

The approach here is to use Terraform to create all the cloud resources. By
using the `google_image_nixos_custom` module it's possible to pre-build images in
auto-scaling scenarios. Or use a push model similar to NixOps with the generic
`deploy_nixos` module.

So overall Terraform + Nix is more flexible and scales better. But it's also
more cumbersome to use as it requires to learn two languages instead of one
and the integration between both is also a bit clunky.

## Terraform Modules

The list of modules provided by this project:

* [deploy_nixos](deploy_nixos#readme) - deploy NixOS onto running NixOS
  machines
* [google_image_nixos](google_image_nixos#readme) - setup an official GCE
  image into a Google Cloud Project.  
* [google_image_nixos_custom](google_image_nixos_custom#readme) - build and
  deploy a custom GCE image into a Google Cloud Project

## Examples

To better understand how these modules can be used together, look into the
[./examples](examples) folder.

## Related projects

* [terraform-provider-nix](https://github.com/andrewchambers/terraform-provider-nix)

## Future

* Support other cloud providers.
* Support nixos-infect bootstrapping method.

Contributions are welcome!

## Thanks

Thanks to [Digital Asset][digital-asset] for generously sponsoring this work!

Thanks to [Tweag][tweag] for enabling this work and the continuous support!

## License

This code is released under the Apache 2.0 License. Please see
[LICENSE](LICENSE) for more details.

Copyright &copy; 2018 Tweag I/O.


[digital-asset]: https://www.digitalasset.com/
[nix]: https://nixos.org/nix/
[terraform]: https://www.terraform.io
[tweag]: https://www.tweag.io/
