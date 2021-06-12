#! /usr/bin/env bash
set -euo pipefail

# Args
nix_path=$1
config=$2
config_pwd=$3
shift 3


command=(nix-instantiate --show-trace --expr '
  { system, configuration, hermetic ? false, argumentsJson, ... }:
  let
    arguments = builtins.fromJSON argumentsJson;

    os =
      if hermetic
        then
          let
            config = import configuration;
          in
          if builtins.isFunction config
            then config arguments
            else config
        else import <nixpkgs/nixos> { inherit system configuration; };
  in {
    inherit (builtins) currentSystem;

    substituters =
      builtins.concatStringsSep " " os.config.nix.binaryCaches;

    trusted-public-keys =
      builtins.concatStringsSep " " os.config.nix.binaryCachePublicKeys;

    drv_path = os.config.system.build.toplevel.drvPath;
    out_path = os.config.system.build.toplevel;
  }')

if readlink --version | grep -q GNU; then
  readlink="readlink -f"
else
  if command -v greadlink &> /dev/null; then
    readlink="greadlink -f"
  else
    echo "Warning: symlinks not supported because readlink is non GNU" >&2
    readlink="realpath"
  fi
fi

if [[ -f "$config" ]]; then
  config=$($readlink "$config")
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
cd "$($readlink "$config_pwd")"

# Instantiate
echo "running (instantiating): ${NIX_PATH:+NIX_PATH=$NIX_PATH} ${command[*]@Q}" -A out_path >&2
"${command[@]}" -A out_path >/dev/null

# Evaluate some more details,
# relying on preceding "Instantiate" command to perform the instantiation,
# because `--eval` is required but doesn't instantiate for some reason.
echo "running (evaluating): ${NIX_PATH:+NIX_PATH=$NIX_PATH} ${command[*]@Q}" --eval --strict --json >&2
"${command[@]}" --eval --strict --json
