#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
device_id="${1:?Pass a booted iPad simulator UDID}"
controller_source="${2:-HH_Kiosk_B2B/Utils/FaceScanManager.swift}"
test_dir="$(mktemp -d /tmp/hh-scan-rotation-tests.XXXXXX)"
app_dir="$test_dir/ScanRotationTests.app"
mkdir -p "$app_dir"
python3 - "$app_dir/Info.plist" "$controller_source" "$test_dir/ScanController.swift" <<'PY'
import plistlib, sys
from pathlib import Path
with open(sys.argv[1], 'wb') as f:
    plistlib.dump({'CFBundleIdentifier':'local.codex.ScanRotationTests','CFBundleExecutable':'ScanRotationTests','CFBundleName':'ScanRotationTests','CFBundlePackageType':'APPL','MinimumOSVersion':'18.0','UIDeviceFamily':[2],'UIRequiresFullScreen':True,'UILaunchScreen':{},'UISupportedInterfaceOrientations':['UIInterfaceOrientationPortrait','UIInterfaceOrientationPortraitUpsideDown','UIInterfaceOrientationLandscapeLeft','UIInterfaceOrientationLandscapeRight']}, f)
source = Path(sys.argv[2]).read_text()
assert '\nclass FaceScanManager:' in source
source = source.split('\nclass FaceScanManager:', 1)[0]
source = source.replace('import AnuraCore\n', '')
source = source.replace('private final class OrientationAwareAnuraMeasurementViewController', 'final class OrientationAwareAnuraMeasurementViewController')
Path(sys.argv[3]).write_text(source)
PY
xcrun swiftc -sdk "$(xcrun --sdk iphonesimulator --show-sdk-path)" \
  -target arm64-apple-ios18.0-simulator -module-cache-path "$test_dir/module-cache" \
  Tests/ScanRotationSimulatorTests.swift "$test_dir/ScanController.swift" \
  HH_Kiosk_B2B/Utils/LandscapeScanPresentationController.swift \
  HH_Kiosk_B2B/Utils/LandscapeMeasurementLayout.swift \
  HH_Kiosk_B2B/Utils/MeasurementBrightnessSession.swift \
  HH_Kiosk_B2B/Utils/MeasurementCameraPreviewOrientation.swift \
  HH_Kiosk_B2B/Utils/MeasurementScreenLightAppearance.swift \
  -o "$app_dir/ScanRotationTests"
xcrun simctl install "$device_id" "$app_dir"
xcrun simctl launch --terminate-running-process --console "$device_id" local.codex.ScanRotationTests
container="$(xcrun simctl get_app_container "$device_id" local.codex.ScanRotationTests data)"
cat "$container/Documents/result.txt"
printf 'Scan popup previews: %s/Documents\n' "$container"
