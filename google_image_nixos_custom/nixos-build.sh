#!/usr/bin/env bash
# Special version of nix-build that integrates with the Terraform external
# provider
set -euo pipefail

nixos_config=$(readlink -f "${1:-./configuration.nix}")

shift

args=(
  --arg configuration "$nixos_config"
  --argstr system x86_64-linux
  --no-out-link
  -A config.system.build.googleComputeImage
)

out_path=$(nix-build '<nixpkgs/nixos>' "${args[@]}" "$@")

image_path=
for path in "$out_path"/*.tar.gz; do
  image_path=$path
done

cat <<JSON
{
  "out_path": "$out_path",
  "image_path": "$image_path"
}
JSON
