#!/usr/bin/env bash
# Special version of nix-build that integrates with the Terraform external
# provider
set -euo pipefail

nix_path="${1}"
nixos_config=$(readlink -f "${2:-./configuration.nix}")

shift
shift

if [[ -n "$nix_path" && "$nix_path" != "-" ]]; then
  export NIX_PATH=$nix_path
fi

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
