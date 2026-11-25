#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
device_id="${1:?Pass a booted iPad simulator UDID}"
test_dir="$(mktemp -d /tmp/hh-save-toast-tests.XXXXXX)"
trap 'rm -rf "$test_dir"' EXIT
app_dir="$test_dir/ScanSaveToastTests.app"
mkdir -p "$app_dir"
python3 - "$app_dir/Info.plist" <<'PY'
import plistlib, sys
with open(sys.argv[1], 'wb') as f:
    plistlib.dump({'CFBundleIdentifier': 'local.codex.ScanSaveToastTests', 'CFBundleExecutable': 'ScanSaveToastTests', 'CFBundleName': 'ScanSaveToastTests', 'CFBundlePackageType': 'APPL', 'MinimumOSVersion': '18.0', 'UIDeviceFamily': [2], 'UILaunchScreen': {}, 'UISupportedInterfaceOrientations': ['UIInterfaceOrientationPortrait', 'UIInterfaceOrientationLandscapeLeft', 'UIInterfaceOrientationLandscapeRight']}, f)
PY
xcrun --sdk iphonesimulator swiftc -sdk "$(xcrun --sdk iphonesimulator --show-sdk-path)" \
  -target arm64-apple-ios18.0-simulator -module-cache-path "$test_dir/module-cache" \
  HH_Kiosk_B2B/Utils/ScanSaveToast.swift \
  HH_Kiosk_B2B/Services/Models/ReportEmailDelivery.swift \
  Tests/ScanSaveToastSimulatorTests.swift \
  -o "$app_dir/ScanSaveToastTests"
xcrun simctl install "$device_id" "$app_dir"
xcrun simctl launch --terminate-running-process --console "$device_id" local.codex.ScanSaveToastTests
container="$(xcrun simctl get_app_container "$device_id" local.codex.ScanSaveToastTests data)"
cat "$container/Documents/result.txt"
printf 'Toast screenshots: %s/Documents/save-confirmation.png and email-failure.png\n' "$container"
