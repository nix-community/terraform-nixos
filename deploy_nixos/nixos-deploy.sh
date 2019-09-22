#!/usr/bin/env bash
# nixos-deploy deploys a nixos-instantiate-generated drvPath to a target host
#
# Usage: nixos-deploy.sh <drvPath> <host> <switch-action> [<build-opts>] ignoreme
set -euo pipefail

### Defaults ###

buildArgs=(
  --option extra-binary-caches https://cache.nixos.org/
)
profile=/nix/var/nix/profiles/system
sshOpts=(
  -o "ControlMaster=auto"
  -o "ControlPersist=60"
  -o "ControlPath=${HOME}/.ssh/deploy_nixos_%C"
  # Avoid issues with IP re-use. This disable TOFU security.
  -o "StrictHostKeyChecking=no"
  -o "UserKnownHostsFile=/dev/null"
  -o "GlobalKnownHostsFile=/dev/null"
)

### Functions ###

log() {
  echo "--- $*" >&2
}

copyToTarget() {
  NIX_SSHOPTS="${sshOpts[*]}" nix-copy-closure --to "$targetHost" "$@"
}

# assumes that passwordless sudo is enabled on the server
targetHostCmd() {
  # ${*@Q} escapes the arguments losslessly into space-separted quoted strings.
  # `ssh` did not properly maintain the array nature of the command line,
  # erroneously splitting arguments with internal spaces, even when using `--`.
  # Tested with OpenSSH_7.9p1.
  ssh "${sshOpts[@]}" "$targetHost" "./maybe-sudo.sh ${*@Q}"
}

### Main ###

# Argument parsing
drvPath="$1"
targetHost="$2"
action="$3"
shift
shift
shift
# remove the last argument
set -- "${@:1:$(($# - 1))}"
buildArgs+=("$@")

# Ensure the local SSH directory exists
mkdir -m 0700 -p "$HOME"/.ssh

# Build derivation
log "building nix code"
outPath=$(nix-store --realize "$drvPath" "${buildArgs[@]}")

# Upload build results
log "uploading build results"
copyToTarget "$outPath" --gzip --use-substitutes

# Activate
log "activating configuration"
targetHostCmd nix-env --profile "$profile" --set "$outPath"
targetHostCmd "$outPath/bin/switch-to-configuration" "$action"

# Cleanup previous generations
log "collecting old nix derivations"
targetHostCmd "nix-collect-garbage" "-d"
