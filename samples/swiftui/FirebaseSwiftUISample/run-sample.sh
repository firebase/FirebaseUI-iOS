#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_PATH="$SCRIPT_DIR/FirebaseSwiftUISample.xcodeproj"
SCHEME="FirebaseSwiftUISample"
APP_NAME="FirebaseSwiftUISample"
BUNDLE_ID="io.flutter.plugins.firebase.auth.example"
CONFIG_PATH="$SCRIPT_DIR/GoogleService-Info.plist"
DERIVED_DATA_PATH="$SCRIPT_DIR/.build/DerivedData"

usage() {
  cat <<EOF
Usage: $(basename "$0")

Builds, installs, and launches the Firebase SwiftUI sample app in the iOS simulator.

Optional environment variables:
  IOS_SIMULATOR_DEVICE   Preferred simulator name (for example: "iPhone 17")

Requirements:
  - Xcode command line tools installed
  - A valid GoogleService-Info.plist at:
    $CONFIG_PATH
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ ! -f "$CONFIG_PATH" ]]; then
  cat <<EOF
Missing Firebase config: $CONFIG_PATH

Download GoogleService-Info.plist from the Firebase console and place it in:
  samples/swiftui/FirebaseSwiftUISample/GoogleService-Info.plist
EOF
  exit 1
fi

if ! command -v xcodebuild >/dev/null 2>&1; then
  echo "xcodebuild is required but was not found."
  exit 1
fi

if ! command -v xcrun >/dev/null 2>&1; then
  echo "xcrun is required but was not found."
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 is required but was not found."
  exit 1
fi

resolve_simulator() {
  python3 - <<'PY'
import json
import os
import re
import subprocess
import sys

preferred_name = os.environ.get("IOS_SIMULATOR_DEVICE")
fallback_names = ["iPhone 17", "iPhone 16 Pro", "iPhone 16", "iPhone 15 Pro"]
runtime_pattern = re.compile(r"com\.apple\.CoreSimulator\.SimRuntime\.iOS-(\d+)(?:-(\d+))?(?:-\d+)?")

try:
    raw = subprocess.check_output(
        ["xcrun", "simctl", "list", "devices", "available", "-j"],
        text=True,
        stderr=subprocess.STDOUT,
    )
except subprocess.CalledProcessError as exc:
    output = exc.output.strip()
    details = f"\n\nsimctl output:\n{output}" if output else ""
    sys.exit(
        "Failed to query available iOS simulators. "
        "Make sure Xcode is installed and CoreSimulator is available."
        f"{details}"
    )
devices_by_runtime = json.loads(raw)["devices"]

candidates = []

for runtime_key, devices in devices_by_runtime.items():
    match = runtime_pattern.fullmatch(runtime_key)
    if not match:
        continue

    version = (int(match.group(1)), int(match.group(2) or 0))
    for device in devices:
        if not device.get("isAvailable"):
            continue
        name = device.get("name")
        candidates.append((version, name, device["udid"]))

if not candidates:
    sys.exit("No available iOS simulators found.")

if preferred_name:
    named = [entry for entry in candidates if entry[1] == preferred_name]
    if not named:
        sys.exit(
            f'No available simulator named "{preferred_name}" was found. '
            "Set IOS_SIMULATOR_DEVICE to a valid installed device name."
        )
    named.sort(reverse=True)
    print(f"{named[0][2]}\t{named[0][1]}")
    sys.exit(0)

for fallback_name in fallback_names:
    named = [entry for entry in candidates if entry[1] == fallback_name]
    if named:
        named.sort(reverse=True)
        print(f"{named[0][2]}\t{named[0][1]}")
        sys.exit(0)

iphone_candidates = [entry for entry in candidates if "iPhone" in entry[1]]
iphone_candidates.sort(reverse=True)
selected = iphone_candidates[0] if iphone_candidates else sorted(candidates, reverse=True)[0]
print(f"{selected[2]}\t{selected[1]}")
PY
}

SIMULATOR_INFO="$(resolve_simulator)"
IFS=$'\t' read -r SIMULATOR_UDID SIMULATOR_NAME <<< "$SIMULATOR_INFO"

if [[ -z "${SIMULATOR_UDID:-}" ]]; then
  echo "Failed to resolve an iOS simulator device."
  exit 1
fi

echo "Using simulator: ${SIMULATOR_NAME:-unknown} ($SIMULATOR_UDID)"

if ! boot_output="$(xcrun simctl boot "$SIMULATOR_UDID" 2>&1)"; then
  if [[ "$boot_output" != *"Unable to boot device in current state: Booted"* ]]; then
    echo "$boot_output"
    exit 1
  fi
fi

xcrun simctl bootstatus "$SIMULATOR_UDID" -b
open -a Simulator

echo "Building $APP_NAME..."
xcodebuild \
  -project "$PROJECT_PATH" \
  -scheme "$SCHEME" \
  -configuration Debug \
  -sdk iphonesimulator \
  -destination "id=$SIMULATOR_UDID" \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  ONLY_ACTIVE_ARCH=YES \
  -quiet \
  build

APP_PATH="$DERIVED_DATA_PATH/Build/Products/Debug-iphonesimulator/$APP_NAME.app"

if [[ ! -d "$APP_PATH" ]]; then
  echo "Built app was not found at: $APP_PATH"
  exit 1
fi

xcrun simctl uninstall "$SIMULATOR_UDID" "$BUNDLE_ID" >/dev/null 2>&1 || true
xcrun simctl install "$SIMULATOR_UDID" "$APP_PATH"
xcrun simctl launch "$SIMULATOR_UDID" "$BUNDLE_ID"

echo
echo "Sample app is running in the simulator."
