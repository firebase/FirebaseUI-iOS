#!/usr/bin/env bash

set -euo pipefail

if [[ -z "${IOS_SIMULATOR_DEVICE:-}" ]]; then
  echo "IOS_SIMULATOR_DEVICE must be set."
  exit 1
fi

echo "--- Available simulators (diagnostic) ---"
xcrun simctl list

SIMULATOR_UDID="$(python3 - <<'PY'
import json
import os
import re
import subprocess
import sys

target_name = os.environ["IOS_SIMULATOR_DEVICE"]
raw = subprocess.check_output(
    ["xcrun", "simctl", "list", "devices", "available", "-j"],
    text=True,
)
devices_by_runtime = json.loads(raw)["devices"]
pattern = re.compile(r"com\.apple\.CoreSimulator\.SimRuntime\.iOS-(\d+)(?:-(\d+))?")

candidates = []
for runtime_key, devices in devices_by_runtime.items():
    match = pattern.fullmatch(runtime_key)
    if not match:
        continue

    version = (int(match.group(1)), int(match.group(2) or 0))
    for device in devices:
        if device.get("isAvailable") and device.get("name") == target_name:
            candidates.append((version, device["udid"]))

if not candidates:
    sys.exit(f"No available simulator found for {target_name} in installed iOS runtimes.")

candidates.sort(reverse=True)
print(candidates[0][1])
PY
)"

if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
  echo "udid=$SIMULATOR_UDID" >> "$GITHUB_OUTPUT"
else
  echo "Resolved simulator UDID: $SIMULATOR_UDID"
fi

if ! boot_output="$(xcrun simctl boot "$SIMULATOR_UDID" 2>&1)"; then
  if [[ "$boot_output" != *"Unable to boot device in current state: Booted"* ]]; then
    echo "$boot_output"
    exit 1
  fi
fi

xcrun simctl bootstatus "$SIMULATOR_UDID" -b
