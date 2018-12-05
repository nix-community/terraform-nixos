#!/usr/bin/env bash
#
# Run sudo if required
#
# Usage: ./maybe-sudo.sh <command> [...args]
set -euo pipefail
if [[ "$UID" = 0 ]]; then
  exec -- "$@"
else
  exec sudo -- "$@"
fi
