#!/usr/bin/env bash
# WSL/Docker Linux Swift -> Windows AdaptiveCardsDemo.exe -> Wine parity.
set -euo pipefail

bridge_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
config="$bridge_root/dist/xwin-sdk/paths.env"

if command -v pwsh.exe >/dev/null 2>&1; then
  prepare_windows="$(wslpath -w "$bridge_root/scripts/prepare-xwin-sdk.ps1")"
  pwsh.exe -NoProfile -ExecutionPolicy Bypass -File "$prepare_windows"
elif [[ ! -f "$config" ]]; then
  echo 'FAIL: no prepared xwin SDK metadata and pwsh.exe is unavailable.'
  echo 'Run scripts/prepare-xwin-sdk.ps1 on Windows first.'
  exit 1
fi

[[ -f "$config" ]] || { echo "FAIL: missing $config"; exit 1; }
# shellcheck disable=SC1090
source "$config"
required=(WINDOWS_SDK XWIN_SYSROOT MSVC_ROOT WINDOWS_KIT_ROOT
          WINDOWS_KIT_VERSION SWIFT_RUNTIME SWIFT_VERSION)
for name in "${required[@]}"; do
  [[ -n "${!name:-}" ]] || { echo "FAIL: $name missing from $config"; exit 1; }
done
for path in "$WINDOWS_SDK" "$XWIN_SYSROOT" "$MSVC_ROOT" \
            "$WINDOWS_KIT_ROOT" "$SWIFT_RUNTIME"; do
  [[ -d "$path" ]] || { echo "FAIL: configured path missing: $path"; exit 1; }
done

SWIFT_IMAGE="${SWIFT_IMAGE:-swift:${SWIFT_VERSION}-jammy}"
XWIN_IMAGE="${XWIN_IMAGE:-adaptivecards-swiftbox-xwin:${SWIFT_VERSION}}"
echo "== image: $XWIN_IMAGE (matching Windows SDK $SWIFT_VERSION) =="
docker build --build-arg "BASE=$SWIFT_IMAGE" -t "$XWIN_IMAGE" \
  -f "$bridge_root/scripts/Dockerfile.xwin" "$bridge_root/scripts"

stage="$(mktemp -d)"
trap 'rm -rf "$stage"' EXIT
tar --exclude=./.build --exclude=./dist -C "$bridge_root" -cf - . | tar -C "$stage" -xf -
out="$bridge_root/dist/xwin-output"
rm -rf "$out"
mkdir -p "$out"

DockerRun=(docker run --rm
  -e "WINDOWS_KIT_VERSION=$WINDOWS_KIT_VERSION"
  -e XDG_RUNTIME_DIR=/tmp/xdg -e WINEDEBUG=-all
  -v "$stage:/src:ro"
  -v "$WINDOWS_SDK:/winsdk:ro"
  -v "$XWIN_SYSROOT:/xwin:ro"
  -v "$MSVC_ROOT:/msvc:ro"
  -v "$WINDOWS_KIT_ROOT:/winkit:ro"
  -v "$SWIFT_RUNTIME:/runtime:ro"
  -v "$out:/out"
  "$XWIN_IMAGE" bash /src/scripts/xwin-container.sh)
"${DockerRun[@]}"

echo "PASS adaptivecards swiftbox xwin lane; artifacts: $out"
