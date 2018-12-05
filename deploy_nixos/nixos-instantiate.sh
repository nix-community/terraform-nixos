#! /usr/bin/env nix-shell
#! nix-shell -p coreutils -i bash
set -euo pipefail

# Args
nix_path=$1
config=$2
config_pwd=$3
shift
shift
shift

# Building the command
command=(nix-instantiate "<nixpkgs/nixos>")

if [[ -f "$config" ]]; then
  config=$(readlink -f "$config")
  command+=(--argstr configuration "$config")
else
  command+=(--arg configuration "$config")
fi

# add all extra CLI args as extra build arguments
command+=("$@")

# Setting the NIX_PATH
if [[ -n "$nix_path" && "$nix_path" != "-" ]]; then
  export NIX_PATH=$nix_path
fi

# Changing directory
cd "$(readlink -f "$config_pwd")"

# Run!
echo "running: ${command[*]@Q}" >&2
drv_path=$("${command[@]}")

if [[ "$drv_path" != /nix/store/*.drv ]]; then
  echo "Bad output: $drv_path" >&2
  exit 1
fi

# Output
cat <<JSON
{
  "drv_path": "$drv_path"
}
JSON
