#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
test_dir="$(mktemp -d /tmp/hh-network-tests.XXXXXX)"
trap 'rm -rf "$test_dir"' EXIT
# Substitute only the OS path source; keep production timing and logic intact.
sed '/^import Network$/d' HH_Kiosk_B2B/Utils/FaceScanNetworkMonitor.swift > "$test_dir/FaceScanNetworkMonitor.swift"
xcrun swiftc -module-cache-path "$test_dir/module-cache" \
  Tests/Support/FaceScanNetworkPathDouble.swift \
  Tests/FaceScanNetworkMonitorTests.swift \
  "$test_dir/FaceScanNetworkMonitor.swift" \
  -o "$test_dir/FaceScanNetworkMonitorTests"
"$test_dir/FaceScanNetworkMonitorTests"
