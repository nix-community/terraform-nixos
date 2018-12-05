#!/usr/bin/env nix-shell
#!nix-shell -p coreutils openssh -i bash
#
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
  NIX_SSHOPTS="${sshOpts[*]}" nix-copy-closure --to "$targetHost" "$1"
}

# assumes that passwordless sudo is enabled on the server
targetHostCmd() {
  ssh "${sshOpts[@]}" "$targetHost" -- ./maybe-sudo.sh "$@"
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

# Setup SSH
sshTmpDir=$(mktemp -t -d nixos-rebuild.XXXXXX)
sshOpts+=(-o "ControlPath=$sshTmpDir/ssh-%n")
sshCleanup() {
  for ctrl in "$sshTmpDir"/ssh-*; do
    ssh -o ControlPath="$ctrl" -O exit dummyhost 2>/dev/null || true
  done
  rm -rf "$sshTmpDir"
}
trap sshCleanup EXIT

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
