#!/usr/bin/env bash
# POSIX runtime symbol-check. Linux/macOS toolchains provide zlib through the
# host SDK/package manager, so no vcpkg flags are required here.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PASS='PASS adaptivecards-swiftmaestro-runtime'
cd "$HERE"

swift build -c debug
BIN="$(swift build -c debug --show-bin-path)/AdaptiveCardsDemo"
[[ -x "$BIN" ]] || { echo "missing executable: $BIN" >&2; exit 1; }
OUTPUT="$("$BIN" 2>&1)"
printf '%s\n' "$OUTPUT"
grep -Fq "$PASS" <<<"$OUTPUT"
echo "smoke OK: '$PASS' observed"
