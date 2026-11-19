#!/bin/bash
set -euo pipefail
umask 077
if [ "$#" -ne 2 ]; then
  echo 'Usage: Scripts/store-payload-credential.sh HOST X-Public-Client-Key (or X-Kiosk-Key / KIOSK_ANURA_API_KEY)' >&2
  exit 1
fi
repo_root="$(cd "$(dirname "$0")/.." && pwd)"
tool_dir="$(mktemp -d /tmp/hh-payload-credential.XXXXXX)"
trap 'unset credential_value; rm -rf "$tool_dir"' EXIT
xcrun --sdk macosx swiftc -module-cache-path "$tool_dir/module-cache" \
  "$repo_root/Scripts/PayloadCredentialTool.swift" -o "$tool_dir/provision"
read -r -s -p 'API key (hidden): ' credential_value
echo
printf '%s' "$credential_value" | "$tool_dir/provision" store "$1" "$2"
