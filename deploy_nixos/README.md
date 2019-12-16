# deploy_nixos

A Terraform module that knows how to deploy NixOS onto a target host.

This allow to describe an infrastructure as code with Terraform and delegate
the machine configuration with NixOS. All directed by Terraform.

The advantage of this method is that if any of the Nix code changes, the
difference will be detected on the next "terraform plan".

## Usage

Either pass a "config" which is a dynamic nixos configuration and a
"config_pwd", or a "nixos_config", a path to a nixos configuration.nix file.

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
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| NIX\_PATH | Allow to pass custom NIX_PATH. Ignored if `-`. | string | `-` | no |
| config | NixOS configuration to be evaluated. This argument is required unless 'nixos_config' is given | string | `` | no |
| config\_pwd | Directory to evaluate the configuration in. This argument is required if 'config' is given | string | `` | no |
| extra\_build\_args | List of arguments to pass to the nix builder | list | `<list>` | no |
| extra\_eval\_args | List of arguments to pass to the nix evaluation | list | `<list>` | no |
| keys | A map of filename to content to upload as secrets in /var/keys | map | `<map>` | no |
| nixos\_config | Path to a NixOS configuration | string | `` | no |
| target\_host | DNS host to deploy to | string | - | yes |
| target\_user | SSH user used to connect to the target_host | string | `root` | no |
| ssh_private_key_file | SSH private key used to connect to the target host | string | unset | no |
| triggers | Triggers for deploy | map | `<map>` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | random ID that changes on every nixos deployment |

<!-- terraform-docs-end -->
