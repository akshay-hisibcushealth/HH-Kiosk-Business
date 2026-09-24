#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
device_id="${1:?Pass a booted iPad simulator UDID}"
test_dir="$(mktemp -d /tmp/hh-keyboard-tests.XXXXXX)"
app_dir="$test_dir/KeyboardPreview.app"
mkdir -p "$app_dir"
python3 - "$app_dir/Info.plist" <<'PY'
import plistlib, sys
with open(sys.argv[1], 'wb') as f:
    plistlib.dump({'CFBundleIdentifier':'local.codex.KeyboardPreview','CFBundleExecutable':'KeyboardPreview','CFBundleName':'KeyboardPreview','CFBundleDevelopmentRegion':'en','CFBundlePackageType':'APPL','MinimumOSVersion':'18.0','UIDeviceFamily':[2],'UILaunchScreen':{},'UISupportedInterfaceOrientations':['UIInterfaceOrientationPortrait','UIInterfaceOrientationLandscapeLeft','UIInterfaceOrientationLandscapeRight']},f)
PY
xcrun swiftc -sdk "$(xcrun --sdk iphonesimulator --show-sdk-path)" \
  -target arm64-apple-ios18.0-simulator -module-cache-path "$test_dir/module-cache" \
  Tests/CompactKeyboardSimulatorTests.swift \
  HH_Kiosk_B2B/Views/Helper_Component/KioskTextField.swift \
  HH_Kiosk_B2B/Views/Helper_Component/CompactKeyboardView.swift \
  HH_Kiosk_B2B/Views/Helper_Component/PersistentVerticalScrollbar.swift \
  HH_Kiosk_B2B/Views/Helper_Component/physical_attribute_components/ProfileEmailSection.swift \
  HH_Kiosk_B2B/Views/Helper_Component/physical_attribute_components/ProfilePINSection.swift \
  HH_Kiosk_B2B/Views/Helper_Component/physical_attribute_components/ProfileWeightSection.swift \
  HH_Kiosk_B2B/Views/Helper_Component/physical_attribute_components/ProfileAgeSection.swift \
  HH_Kiosk_B2B/Views/Helper_Component/physical_attribute_components/PhysicalAttributesScrollView.swift \
  HH_Kiosk_B2B/Views/Helper_Component/KeyboardObserver.swift \
  HH_Kiosk_B2B/Resources/Strings.swift \
  HH_Kiosk_B2B/Utils/KioskTextInput.swift \
  HH_Kiosk_B2B/Utils/PhysicalAttributesInputField.swift \
  HH_Kiosk_B2B/Utils/Screen.swift \
  HH_Kiosk_B2B/Resources/AppColors.swift \
  HH_Kiosk_B2B/Utils/Extensions/UIColorExtensions.swift \
  -o "$app_dir/KeyboardPreview"
xcrun simctl install "$device_id" "$app_dir"
xcrun simctl launch --terminate-running-process --console "$device_id" local.codex.KeyboardPreview
container="$(xcrun simctl get_app_container "$device_id" local.codex.KeyboardPreview data)"
cat "$container/Documents/result.txt"
cat "$container/Documents/rotation.txt"
cat "$container/Documents/profile.txt"
cat "$container/Documents/scroll.txt"
cat "$container/Documents/sizing.txt"
printf 'Keyboard previews: %s/Documents\n' "$container"
