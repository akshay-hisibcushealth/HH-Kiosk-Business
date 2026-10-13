#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
device_id="${1:?Pass a booted iPad simulator UDID}"
screen_source="${2:-HH_Kiosk_B2B/Views/Screens/ScreenSaver.swift}"
test_dir="$(mktemp -d /tmp/hh-screen-saver-tests.XXXXXX)"
app_dir="$test_dir/ScreenSaverLayoutTests.app"
mkdir -p "$app_dir" "$test_dir/Assets.xcassets"
python3 - "$app_dir/Info.plist" "$screen_source" "$test_dir/ScreenSaver.swift" <<'PY'
import plistlib, sys
from pathlib import Path
with open(sys.argv[1], 'wb') as f:
    plistlib.dump({'CFBundleIdentifier':'local.codex.ScreenSaverLayoutTests','CFBundleExecutable':'ScreenSaverLayoutTests','CFBundleName':'ScreenSaverLayoutTests','CFBundleDevelopmentRegion':'en','CFBundlePackageType':'APPL','MinimumOSVersion':'18.0','UIDeviceFamily':[2],'UILaunchScreen':{},'UIAppFonts':['NewSpirit-Semibold.otf'],'UISupportedInterfaceOrientations':['UIInterfaceOrientationPortrait','UIInterfaceOrientationLandscapeLeft','UIInterfaceOrientationLandscapeRight']}, f)
s = Path(sys.argv[2]).read_text()
for anchor, layout in [('landscapeContent(size: geometry.size)', 'landscape'), ('portraitContent\n', 'portrait')]:
    assert anchor in s, f'Update layout instrumentation for {layout}'
    s = s.replace(anchor, anchor.rstrip() + '\n.onAppear { ScreenSaverLayoutProbe.displayedLayout = "' + layout + '" }\n', 1)
probes = {
    '.minimumScaleFactor(0.72)': 'heading',
    '.minimumScaleFactor(0.78)': 'subtitle',
    '.frame(width: 630.w, height: 670.h)': 'avatar',
    'ScreenSaverFaceScanButton(text: actionButtonText, action: onStartFaceScan)': 'button',
    'ScreenSaverFaceScanButton(text: actionButtonText, action: onStartFaceScan, fitsAvailableWidth: true)': 'landscapeButton',
    '.frame(width: size.width * 0.38, height: size.height * 0.64)': 'landscapeAvatar',
}
for anchor, key in probes.items():
    assert anchor in s, f'Update geometry instrumentation for {key}'
    s = s.replace(anchor, anchor + '\n.onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: { ScreenSaverLayoutProbe.frames["' + key + '"] = $0 }', 1)
Path(sys.argv[3]).write_text(s)
PY
for asset in logo ss_avatar screensaverbg smile; do
  cp -R "HH_Kiosk_B2B/Resources/Assets.xcassets/$asset.imageset" "$test_dir/Assets.xcassets/"
done
cp HH_Kiosk_B2B/Resources/NewSpirit-Semibold.otf "$app_dir/"
xcrun actool "$test_dir/Assets.xcassets" --compile "$app_dir" --platform iphonesimulator --minimum-deployment-target 18.0 --target-device ipad > "$test_dir/assets.log" 2>&1
xcrun swiftc -sdk "$(xcrun --sdk iphonesimulator --show-sdk-path)" \
  -target arm64-apple-ios18.0-simulator -module-cache-path "$test_dir/module-cache" \
  Tests/ScreenSaverLayoutSimulatorTests.swift "$test_dir/ScreenSaver.swift" \
  HH_Kiosk_B2B/Views/Helper_Component/Toolbar.swift \
  HH_Kiosk_B2B/Views/Helper_Component/DateTimeView.swift \
  HH_Kiosk_B2B/Views/Helper_Component/text_helper.swift \
  HH_Kiosk_B2B/Views/Helper_Component/SVGImageView.swift \
  HH_Kiosk_B2B/App/OrientationManager.swift \
  HH_Kiosk_B2B/Services/Models/ScreenSaverData.swift \
  HH_Kiosk_B2B/Resources/Strings.swift \
  HH_Kiosk_B2B/Resources/AppColors.swift \
  HH_Kiosk_B2B/Resources/AppIconNames.swift \
  HH_Kiosk_B2B/Utils/AppStorageKeys.swift \
  HH_Kiosk_B2B/Utils/Screen.swift \
  HH_Kiosk_B2B/Utils/Extensions/UIColorExtensions.swift \
  -o "$app_dir/ScreenSaverLayoutTests"
xcrun simctl install "$device_id" "$app_dir"
xcrun simctl launch --terminate-running-process --console "$device_id" local.codex.ScreenSaverLayoutTests
container="$(xcrun simctl get_app_container "$device_id" local.codex.ScreenSaverLayoutTests data)"
cat "$container/Documents/result.txt"
printf 'Welcome screen previews: %s/Documents\n' "$container"
