#!/bin/bash
set -euo pipefail
umask 077

# Never enable shell tracing: this build step handles credentials.
tool_dir="${DERIVED_FILE_DIR:?}/PayloadCredentialTool"
mkdir -p "$tool_dir"
mac_sdk="$(xcrun --sdk macosx --show-sdk-path)"
xcrun --sdk macosx swiftc -sdk "$mac_sdk" -target "$(uname -m)-apple-macosx14.0" \
  -module-cache-path "$tool_dir/module-cache" \
  "$SRCROOT/Scripts/PayloadCredentialTool.swift" -o "$tool_dir/provision"
"$tool_dir/provision" export "$SRCROOT/HH_Kiosk_B2B/Utils/Config.swift" \
  "$TARGET_BUILD_DIR/$UNLOCALIZED_RESOURCES_FOLDER_PATH/PayloadCredentials.plist"
