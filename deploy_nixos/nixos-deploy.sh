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
  # interactive authentication is not possible
  -o "BatchMode=yes"
  # verbose output for easier debugging
  -v
)

###  Argument parsing ###

drvPath="$1"
outPath="$2"
targetHost="$3"
buildOnTarget="$4"
sshPrivateKeyFile="$5"
action="$6"
shift 6

# remove the last argument
set -- "${@:1:$(($# - 1))}"
buildArgs+=("$@")

if [[ -n "${sshPrivateKeyFile}" && "${sshPrivateKeyFile}" != "-" ]]; then
    sshOpts+=( -o "IdentityFile=${sshPrivateKeyFile}" )
fi

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

# Ensure the local SSH directory exists
mkdir -m 0700 -p "$HOME"/.ssh

if [[ "${buildOnTarget:-false}" == true ]]; then

  # Upload derivation
  log "uploading derivations"
  copyToTarget "$drvPath" --gzip --use-substitutes

  # Build remotely
  log "building on target"
  set -x
  targetHostCmd "nix-store" "--realize" "$drvPath" "${buildArgs[@]}"

else

  # Build derivation
  log "building on deployer"
  outPath=$(nix-store --realize "$drvPath" "${buildArgs[@]}")

  # Upload build results
  log "uploading build results"
  copyToTarget "$outPath" --gzip --use-substitutes

fi

# Activate
log "activating configuration"
targetHostCmd nix-env --profile "$profile" --set "$outPath"
targetHostCmd "$outPath/bin/switch-to-configuration" "$action"

# Cleanup previous generations
log "collecting old nix derivations"
targetHostCmd "nix-collect-garbage" "-d"

# Close ssh multiplex-master process gracefully
log "closing persistent ssh-connection"
sshOpts+=( -O "stop" )
ssh "${sshOpts[@]}" "$targetHost"
