#!/usr/bin/env bash
#
# Unpacks the packed-keys.json into individual keys
set -euo pipefail
shopt -s nullglob

keys_file=${1:-packed-keys.json}
keys_dir=/var/keys

if [[ ! -f "$keys_file" ]]; then
  echo "error: $keys_file not found"
  exit 1
fi

# Fallback if jq is not installed
if ! type -p jq &>/dev/null; then
  jqOut=$(nix-build '<nixpkgs>' -A jq)
  jq() {
    "$jqOut/bin/jq" "$@"
  }
fi

# cleanup
mkdir -m 0750 -p "$keys_dir"
chown -v root:keys "$keys_dir"
chmod -v 0750 "$keys_dir"
for key in "$keys_dir"/* ; do
  rm -v "$key"
done

if [[ $(< "$keys_file") = "{}" ]]; then
  echo "no keys to unpack"
  exit
fi

echo "unpacking $keys_file"

# extract the keys from .packed.json
for keyname in $(jq -S -r 'keys[]' "$keys_file"); do
  echo "unpacking: $keyname"
  jq -r ".\"$keyname\"" < "$keys_file" > "$keys_dir/$keyname"
  chmod 0640 "$keys_dir/$keyname"
  chown root:keys "$keys_dir/$keyname"
done

echo "unpacking done"
