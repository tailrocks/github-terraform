#!/usr/bin/env bash
set -euo pipefail

read -r payload
vault="$(printf '%s' "$payload" | jq -r '.vault // empty')"
item="$(printf '%s' "$payload" | jq -r '.item // empty')"
field="$(printf '%s' "$payload" | jq -r '.field // empty')"
section="$(printf '%s' "$payload" | jq -r '.section // empty')"

if [ -z "$vault" ] || [ -z "$item" ] || [ -z "$field" ]; then
  echo '{"error":"vault, item, and field are required"}'
  exit 1
fi

if ! command -v op >/dev/null 2>&1; then
  echo '{"error":"1Password CLI is not installed"}'
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo '{"error":"jq is not installed"}'
  exit 1
fi

if [ -n "$section" ]; then
  value="$(op read "op://$vault/$item/$section/$field")"
else
  value="$(op read "op://$vault/$item/$field")"
fi

printf '{"value":%s}\n' "$(printf '%s' "$value" | jq -Rsa .)"
