#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
device_id="${1:?Pass a booted iPad simulator UDID}"
output_dir="${2:-/tmp/hh-face-scan-network-results}"
mkdir -p "$output_dir"
test_dir="$(mktemp -d /tmp/hh-network-ui-tests.XXXXXX)"
trap 'rm -rf "$test_dir"' EXIT
app_dir="$test_dir/FaceScanNetworkTests.app"
mkdir -p "$app_dir"
python3 - "$app_dir/Info.plist" <<'PY'
import plistlib, sys
with open(sys.argv[1], 'wb') as f:
    plistlib.dump({'CFBundleIdentifier':'local.codex.FaceScanNetworkTests','CFBundleExecutable':'FaceScanNetworkTests','CFBundleName':'FaceScanNetworkTests','CFBundlePackageType':'APPL','MinimumOSVersion':'18.0','UIDeviceFamily':[2],'UIRequiresFullScreen':True,'UILaunchScreen':{},'UISupportedInterfaceOrientations':['UIInterfaceOrientationPortrait','UIInterfaceOrientationLandscapeLeft','UIInterfaceOrientationLandscapeRight']}, f)
PY
# Stand-ins replace only external boundaries. Do not rewrite production logic.
sed '/^import Network$/d' HH_Kiosk_B2B/Utils/FaceScanNetworkMonitor.swift > "$test_dir/FaceScanNetworkMonitor.swift"
sed '/^import AnuraCore$/d' HH_Kiosk_B2B/Utils/MeasurementDelegate.swift > "$test_dir/MeasurementDelegate.swift"
xcrun --sdk iphonesimulator swiftc -sdk "$(xcrun --sdk iphonesimulator --show-sdk-path)" \
  -target arm64-apple-ios18.0-simulator -module-cache-path "$test_dir/module-cache" \
  Tests/Support/FaceScanNetworkPathDouble.swift \
  Tests/Support/FaceScanDelegateTestDoubles.swift \
  Tests/FaceScanNetworkSimulatorTests.swift \
  "$test_dir/FaceScanNetworkMonitor.swift" "$test_dir/MeasurementDelegate.swift" \
  HH_Kiosk_B2B/Utils/FaceScanNetworkToast.swift \
  HH_Kiosk_B2B/Utils/LandscapeScanPresentationController.swift \
  -o "$app_dir/FaceScanNetworkTests"
xcrun simctl install "$device_id" "$app_dir"
xcrun simctl launch --terminate-running-process --console "$device_id" local.codex.FaceScanNetworkTests
container="$(xcrun simctl get_app_container "$device_id" local.codex.FaceScanNetworkTests data)"
cp "$container/Documents/result.txt" "$output_dir/result.txt"
cp "$container/Documents/network-toast-portrait.png" "$output_dir/"
cp "$container/Documents/network-toast-landscape.png" "$output_dir/"
cat "$output_dir/result.txt"
printf 'Screenshots and results: %s\n' "$output_dir"
