#!/usr/bin/env bash
# examples/adaptivecards-llvmwasm-demo/smoke.sh
#
# Linux/macOS counterpart of smoke.ps1: build + run the control-surface round-trip demo and
# assert the PASS marker. LLVMWasmCore is pure Foundation — no external artifacts.
set -uo pipefail
marker="PASS adaptivecards-llvmwasm-roundtrip"
cd "$(dirname "$0")"

echo "=== swift build (demo) ==="
if ! swift build -c debug; then
    echo "FAIL adaptivecards-llvmwasm-roundtrip: build failed"; exit 1
fi

echo "=== run demo ==="
out="$(swift run -c debug adaptivecards-llvmwasm-demo 2>&1)"; rc=$?
echo "$out"
if [ $rc -ne 0 ]; then
    echo "FAIL adaptivecards-llvmwasm-roundtrip: demo exit=$rc"; exit $rc
fi
if ! printf '%s' "$out" | grep -qF "$marker"; then
    echo "FAIL adaptivecards-llvmwasm-roundtrip: PASS marker not found"; exit 4
fi
echo ""
echo "$marker"
