#!/usr/bin/env bash
# Runs inside Dockerfile.xwin; host orchestration is xwin-roundtrip.sh.
set -euo pipefail

: "${WINDOWS_KIT_VERSION:?WINDOWS_KIT_VERSION is required}"
for path in /src /winsdk /xwin /msvc /winkit /runtime /out; do
  [[ -e "$path" ]] || { echo "FAIL: required mount missing: $path"; exit 1; }
done

cp -a /src /tmp/bridge
example=/tmp/bridge/examples/adaptivecards-swiftbox-demo
cd "$example"

echo '== native Linux AdaptiveCards Swiftbox round trip =='
swift build --product AdaptiveCardsDemo --scratch-path /tmp/linux-build
/tmp/linux-build/debug/AdaptiveCardsDemo > /out/linux-demo.txt
grep -q 'PASS adaptivecards-swiftbox-roundtrip' /out/linux-demo.txt

# Foundation textual interfaces may launch nested compilers. CPATH is inherited
# by those subprocesses; command-line -Xcc flags alone are not.
export CPATH='/xwin/include/msvc:/xwin/include/ucrt:/xwin/include/shared:/xwin/include/um:/xwin/include/winrt'
export CPLUS_INCLUDE_PATH="$CPATH"

common=(
  --triple x86_64-unknown-windows-msvc
  --sdk /winsdk
  -Xswiftc -resource-dir
  -Xswiftc /winsdk/usr/lib/swift
  -Xswiftc -use-ld=lld
  -Xcc -I/xwin/include/msvc
  -Xcc -I/xwin/include/ucrt
  -Xcc -I/xwin/include/shared
  -Xcc -I/xwin/include/um
  -Xcc -I/xwin/include/winrt
  -Xlinker -libpath:/msvc/lib/x64
  -Xlinker -libpath:/winkit/Lib/"$WINDOWS_KIT_VERSION"/ucrt/x64
  -Xlinker -libpath:/winkit/Lib/"$WINDOWS_KIT_VERSION"/um/x64
)

echo '== true Linux -> Windows cross-build of AdaptiveCardsDemo =='
swift build --product AdaptiveCardsDemo --scratch-path /tmp/xwin-build "${common[@]}" 2>&1 | tee /out/xwin-build.txt
cross_exe=/tmp/xwin-build/x86_64-unknown-windows-msvc/debug/AdaptiveCardsDemo.exe
[[ -f "$cross_exe" ]] || { echo 'FAIL: cross-built AdaptiveCardsDemo.exe not found'; exit 1; }
cp "$cross_exe" /out/AdaptiveCardsDemo-cross.exe

echo '== Wine: execute cross-built AdaptiveCardsDemo and assert parity =='
mkdir -p /tmp/xdg /tmp/win
export XDG_RUNTIME_DIR=/tmp/xdg
wineboot -i >/dev/null 2>&1
wineserver -w
cp /out/AdaptiveCardsDemo-cross.exe /tmp/win/
cp /runtime/*.dll /tmp/win/
cd /tmp/win
wine AdaptiveCardsDemo-cross.exe 2>/dev/null | tr -d '\r' > /out/wine-demo.txt
grep -q 'PASS adaptivecards-swiftbox-roundtrip' /out/wine-demo.txt
linux_sha="$(sha256sum /out/linux-demo.txt | cut -d' ' -f1)"
wine_sha="$(sha256sum /out/wine-demo.txt | cut -d' ' -f1)"
echo "linux_demo_sha256=$linux_sha"
echo "wine_demo_sha256 =$wine_sha"
cmp /out/linux-demo.txt /out/wine-demo.txt || {
  echo 'FAIL: cross-built Windows bridge output differs from native Linux'
  diff /out/linux-demo.txt /out/wine-demo.txt | head -40 || true
  exit 1
}
echo "PASS adaptivecards-swiftbox-xwin: Windows(Wine) == Linux ($linux_sha)"
