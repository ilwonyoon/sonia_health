#!/usr/bin/env bash
#
# cartesia-voices.sh — list Cartesia voices using the SAME key the app uses.
#
# Single source of truth for the Cartesia key is SoniaHealth/Config/Secrets.xcconfig
# (gitignored). This script reads CARTESIA_API_KEY from it, so there is no separate
# .env to keep in sync. Update the key in one place — Secrets.xcconfig — and both the
# iOS app and this tooling pick it up.
#
# Usage:
#   scripts/cartesia-voices.sh            # pretty list (id · name · gender · lang · description)
#   scripts/cartesia-voices.sh --raw      # raw JSON
#
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CFG="$REPO_ROOT/SoniaHealth/Config/Secrets.xcconfig"
VERSION="2024-11-13"

if [[ ! -f "$CFG" ]]; then
  echo "error: $CFG not found. Copy Secrets.example.xcconfig and fill in your key." >&2
  exit 1
fi

# Parse the CARTESIA_API_KEY line (xcconfig syntax), strip spaces/quotes.
KEY="$(grep -E '^[[:space:]]*CARTESIA_API_KEY[[:space:]]*=' "$CFG" \
  | head -1 | sed -E 's/^[^=]*=[[:space:]]*//' | tr -d '"' | xargs || true)"

if [[ -z "${KEY:-}" ]]; then
  echo "error: CARTESIA_API_KEY is empty in $CFG" >&2
  exit 1
fi

RESP="$(curl -s -w $'\n%{http_code}' "https://api.cartesia.ai/voices/?limit=100" \
  -H "X-API-Key: $KEY" -H "Cartesia-Version: $VERSION")"
CODE="${RESP##*$'\n'}"
BODY="${RESP%$'\n'*}"

if [[ "$CODE" != "200" ]]; then
  echo "error: Cartesia API returned HTTP $CODE" >&2
  echo "$BODY" >&2
  echo >&2
  echo "If 401: update CARTESIA_API_KEY in $CFG (key may be rotated/expired)." >&2
  exit 1
fi

if [[ "${1:-}" == "--raw" ]]; then
  echo "$BODY"
  exit 0
fi

echo "$BODY" | python3 "$REPO_ROOT/scripts/_format_voices.py"
