# deploy_nixos

A Terraform module that knows how to deploy NixOS onto a target host.

This allow to describe an infrastructure as code with Terraform and delegate
the machine configuration with NixOS. All directed by Terraform.

The advantage of this method is that if any of the Nix code changes, the
difference will be detected on the next "terraform plan".

## Usage

Either pass a "config" which is a dynamic nixos configuration and a
"config_pwd", or a "nixos_config", a path to a nixos configuration.nix file.
If you have defined your NixOs configuration in a Flake, use "nixos_config" 
to specify the name of the attribue and set "flake" to true.

### Secret handling

Keys can be passed to the "keys" attribute. Each key will be installed under
`/var/keys/${key}` with the content as the value.

For services to access one of the keys, add the service user to the "keys"
group.

The target machine needs `jq` installed prior to the deployment (as part of
the base image). If `jq` is not found it will try to use a version from
`<nixpkgs>`.

### Disabling sandboxing

Unfortunately some time it's required to disable the nix sandboxing. To do so,
add `["--option", "sandbox", "false"]` to the "extra_build_args" parameter.

If that doesn't work, make sure that your user is part of the nix
"trusted-users" list.

### Non-root `target_user`

It is possible to connect to the target host using a user that is not `root`
under certain conditions:

* sudo needs to be installed on the machine
* the user needs password-less sudo access on the machine

This would typically be provisioned in the base image.

### Binary cache configuration

One thing that might be surprising is that the binary caches (aka
substituters) are taken from the machine configuration. This implies that the
user Nix configuration will be ignored in that regard.

## Dependencies

* `bash` 4.0+
* `nix`
* `openssh`
* `readlink` with `-f` (coreutils or busybox)

## Known limitations

The deployment machine requires Nix with access to a remote builder with the
same system as the target machine.

Because Nix code is being evaluated at "terraform plan" time, deploying a lot
of machine in the same target will require a lot of RAM.

All the secrets share the same "keys" group.

When deploying as non-root, it assumes that passwordless `sudo` is available.

The target host must already have NixOS installed.

### config including computed values

The module doesn't work when `<computed>` values from other resources are
interpolated with the "config" attribute. Because it happens at evaluation
time, terraform will render an empty drvPath.

see also:
* https://github.com/hashicorp/terraform/issues/16380
* https://github.com/hashicorp/terraform/issues/16762
* https://github.com/hashicorp/terraform/issues/17034

<!-- terraform-docs-start -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12 |

## Providers

| Name | Version |
|------|---------|
| external | n/a |
| null | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| NIX\_PATH | Allow to pass custom NIX\_PATH | `string` | `""` | no |
| build\_on\_target | Avoid building on the deployer. Must be true or false. Has no effect when deploying from an incompatible system. Unlike remote builders, this does not require the deploying user to be trusted by its host. | `string` | `false` | no |
| config | NixOS configuration to be evaluated. This argument is required unless 'nixos\_config' is given | `string` | `""` | no |
| config\_pwd | Directory to evaluate the configuration in. This argument is required if 'config' is given | `string` | `""` | no |
| extra\_build\_args | List of arguments to pass to the nix builder | `list(string)` | `[]` | no |
| extra\_eval\_args | List of arguments to pass to the nix evaluation | `list(string)` | `[]` | no |
| hermetic | Treat the provided nixos configuration as a hermetic expression and do not evaluate using the ambient system nixpkgs. Useful if you customize eval-modules or use a pinned nixpkgs. | `bool` | false | no |
| flake | Treat the provided nixos_config as the name of the NixOS configuration to use in the flake located in the current directory. Useful if you customize eval-modules or use a pinned nixpkgs. | `bool` | false | no |
| keys | A map of filename to content to upload as secrets in /var/keys | `map(string)` | `{}` | no |
| nixos\_config | Path to a NixOS configuration | `string` | `""` | no |
| ssh\_agent | Whether to use an SSH agent. True if not ssh\_private\_key is passed | `bool` | `null` | no |
| ssh\_private\_key | Content of private key used to connect to the target\_host | `string` | `""` | no |
| ssh\_private\_key\_file | Path to private key used to connect to the target\_host | `string` | `""` | no |
| target\_host | DNS host to deploy to | `string` | n/a | yes |
| target\_port | SSH port used to connect to the target\_host | `number` | `22` | no |
| target\_system | Nix system string | `string` | `"x86_64-linux"` | no |
| target\_user | SSH user used to connect to the target\_host | `string` | `"root"` | no |
| triggers | Triggers for deploy | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | random ID that changes on every nixos deployment |

<!-- terraform-docs-end -->
