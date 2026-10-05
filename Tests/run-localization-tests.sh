#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
test_dir="$(mktemp -d /tmp/hh-localization-tests.XXXXXX)"
trap 'rm -rf "$test_dir"' EXIT
app_dir="$test_dir/LocalizationTests.app/Contents"
mkdir -p "$app_dir/MacOS" "$app_dir/Resources"
cp -R HH_Kiosk_B2B/Resources/en.lproj HH_Kiosk_B2B/Resources/es.lproj "$app_dir/Resources/"
python3 - "$app_dir" <<'PY'
import plistlib, sys
from pathlib import Path
app = Path(sys.argv[1])
with (app / 'Info.plist').open('wb') as f:
    plistlib.dump({'CFBundleIdentifier': 'local.codex.HHLocalizationTests', 'CFBundleExecutable': 'LocalizationTests', 'CFBundlePackageType': 'APPL', 'CFBundleDevelopmentRegion': 'en'}, f)
with (app / 'Resources/en.lproj/Localizable.strings').open('a') as f:
    f.write('"test.englishOnly" = "English fallback";\n')
PY
xcrun swiftc -module-cache-path "$test_dir/module-cache" \
  HH_Kiosk_B2B/Resources/AppLocalization.swift \
  HH_Kiosk_B2B/Resources/Strings.swift \
  HH_Kiosk_B2B/Utils/Config.swift \
  Tests/AppLocalizationTests.swift \
  -o "$app_dir/MacOS/LocalizationTests"
"$app_dir/MacOS/LocalizationTests"
