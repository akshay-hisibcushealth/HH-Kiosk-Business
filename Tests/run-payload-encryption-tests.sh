#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
test_dir="$(mktemp -d /tmp/hh-payload-tests.XXXXXX)"
trap 'rm -rf "$test_dir"' EXIT
xcrun swiftc -module-cache-path "$test_dir/module-cache" \
  HH_Kiosk_B2B/Services/Networking/PayloadEncryption.swift \
  HH_Kiosk_B2B/Services/Networking/KioskAnuraEncryption.swift \
  HH_Kiosk_B2B/Services/Networking/PayloadKeyStore.swift \
  HH_Kiosk_B2B/Services/Networking/PayloadRequestPolicy.swift \
  HH_Kiosk_B2B/Services/Networking/AppURLSessionClient.swift \
  HH_Kiosk_B2B/LocalStorageManager/SecureStorage.swift \
  HH_Kiosk_B2B/LocalStorageManager/PayloadCredentialStore.swift \
  HH_Kiosk_B2B/Services/API/AppAPIEndpoints.swift \
  HH_Kiosk_B2B/Services/API/KioskContentService.swift \
  HH_Kiosk_B2B/Utils/Config.swift \
  Tests/PayloadEncryptionTests.swift -o "$test_dir/tests"
"$test_dir/tests"
