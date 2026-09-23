#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
device_id="${1:?Pass a booted iPad simulator UDID}"
test_dir="$(mktemp -d /tmp/hh-brightness-tests.XXXXXX)"
trap 'rm -rf "$test_dir"' EXIT
xcrun swiftc -sdk "$(xcrun --sdk iphonesimulator --show-sdk-path)" \
  -target arm64-apple-ios18.0-simulator -module-cache-path "$test_dir/module-cache" \
  Tests/MeasurementBrightnessSessionTests.swift \
  HH_Kiosk_B2B/Utils/MeasurementBrightnessSession.swift \
  -o "$test_dir/MeasurementBrightnessSessionTests"
xcrun simctl spawn "$device_id" "$test_dir/MeasurementBrightnessSessionTests"
