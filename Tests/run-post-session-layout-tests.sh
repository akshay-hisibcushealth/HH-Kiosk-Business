#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
device_id="${1:?Pass a booted iPad simulator UDID}"
screen_source="${2:-HH_Kiosk_B2B/Views/Screens/PostSessionFlowScreen.swift}"
test_dir="$(mktemp -d /tmp/hh-post-session-tests.XXXXXX)"
app_dir="$test_dir/PostSessionLayoutTests.app"
mkdir -p "$app_dir"
python3 - "$app_dir/Info.plist" "$screen_source" "$test_dir/PostSessionFlowScreen.swift" <<'PY'
import plistlib, sys
from pathlib import Path
with open(sys.argv[1], 'wb') as f:
    plistlib.dump({'CFBundleIdentifier':'local.codex.PostSessionLayoutTests','CFBundleExecutable':'PostSessionLayoutTests','CFBundleName':'PostSessionLayoutTests','CFBundleDevelopmentRegion':'en','CFBundlePackageType':'APPL','MinimumOSVersion':'18.0','UIDeviceFamily':[2],'UILaunchScreen':{},'UISupportedInterfaceOrientations':['UIInterfaceOrientationPortrait','UIInterfaceOrientationLandscapeLeft','UIInterfaceOrientationLandscapeRight']}, f)
s = Path(sys.argv[2]).read_text()
s = s.replace('@State private var step: PostSessionStep = .nextSteps', '@State private var step: PostSessionStep = PostSessionLayoutProbe.showsNPS ? .nps : .nextSteps')
footer = '.fixedSize(horizontal: false, vertical: true)'
viewport = '.persistentVerticalScrollbar()'
assert s.count(footer) == 1 and s.count(viewport) == 1, 'Update geometry instrumentation for the changed screen structure'
s = s.replace(footer, footer + '\n.onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: { PostSessionLayoutProbe.footer = $0 }')
s = s.replace(viewport, viewport + '\n.onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: { PostSessionLayoutProbe.viewport = $0 }')
Path(sys.argv[3]).write_text(s)
PY
xcrun swiftc -sdk "$(xcrun --sdk iphonesimulator --show-sdk-path)" \
  -target arm64-apple-ios18.0-simulator -module-cache-path "$test_dir/module-cache" \
  Tests/PostSessionLayoutSimulatorTests.swift "$test_dir/PostSessionFlowScreen.swift" \
  HH_Kiosk_B2B/Views/Helper_Component/Toolbar.swift \
  HH_Kiosk_B2B/Views/Helper_Component/DateTimeView.swift \
  HH_Kiosk_B2B/Views/Helper_Component/ScanProgressView.swift \
  HH_Kiosk_B2B/Views/Helper_Component/PersistentVerticalScrollbar.swift \
  HH_Kiosk_B2B/Views/Helper_Component/text_helper.swift \
  HH_Kiosk_B2B/App/OrientationManager.swift \
  HH_Kiosk_B2B/Resources/Strings.swift \
  HH_Kiosk_B2B/Resources/AppLocalization.swift \
  HH_Kiosk_B2B/Views/Helper_Component/AppLanguageEnvironment.swift \
  HH_Kiosk_B2B/Utils/Config.swift \
  HH_Kiosk_B2B/Resources/AppColors.swift \
  HH_Kiosk_B2B/Resources/AppIconNames.swift \
  HH_Kiosk_B2B/Utils/Screen.swift \
  HH_Kiosk_B2B/Utils/Extensions/UIColorExtensions.swift \
  -o "$app_dir/PostSessionLayoutTests"
xcrun simctl install "$device_id" "$app_dir"
xcrun simctl launch --terminate-running-process --console "$device_id" local.codex.PostSessionLayoutTests
container="$(xcrun simctl get_app_container "$device_id" local.codex.PostSessionLayoutTests data)"
cat "$container/Documents/result.txt"
