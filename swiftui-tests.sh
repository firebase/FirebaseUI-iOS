#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IOS_SIMULATOR_DEVICE="${IOS_SIMULATOR_DEVICE:-iPhone 17 Pro}"
SIMULATOR_UDID=""
RUN_LINT=false
RUN_UNIT=false
RUN_INTEGRATION=false
RUN_UI=false
EMULATOR_PID=""

usage() {
  cat <<EOF
Usage: ./swiftui-tests.sh [options]

Runs the local equivalents of the SwiftUI Auth GitHub Actions jobs.

Options:
  --all              Run unit, integration, and UI tests (default when no test flag is provided)
  --unit             Run FirebaseSwiftUI package unit tests
  --integration      Run FirebaseSwiftUIExample integration tests
  --ui               Run FirebaseSwiftUIExample UI tests
  --lint             Run Swift format linting before selected tests
  --device NAME      Simulator device name (default: ${IOS_SIMULATOR_DEVICE})
  -h, --help         Show this help

Examples:
  ./swiftui-tests.sh
  ./swiftui-tests.sh --unit
  ./swiftui-tests.sh --integration --ui
  ./swiftui-tests.sh --lint --all
  ./swiftui-tests.sh --device "iPhone 17 Pro" --ui
EOF
}

cleanup() {
  if [[ -n "${EMULATOR_PID}" ]] && kill -0 "${EMULATOR_PID}" 2>/dev/null; then
    echo "Stopping Firebase Auth emulator..."
    kill "${EMULATOR_PID}" 2>/dev/null || true
    wait "${EMULATOR_PID}" 2>/dev/null || true
  fi
}
trap cleanup EXIT

while [[ $# -gt 0 ]]; do
  case "$1" in
    --all)
      RUN_UNIT=true
      RUN_INTEGRATION=true
      RUN_UI=true
      shift
      ;;
    --unit)
      RUN_UNIT=true
      shift
      ;;
    --integration)
      RUN_INTEGRATION=true
      shift
      ;;
    --ui)
      RUN_UI=true
      shift
      ;;
    --lint)
      RUN_LINT=true
      shift
      ;;
    --device)
      if [[ -z "${2:-}" ]]; then
        echo "--device requires a simulator device name."
        exit 1
      fi
      IOS_SIMULATOR_DEVICE="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      usage
      exit 1
      ;;
  esac
done

if [[ "${RUN_UNIT}" == false && "${RUN_INTEGRATION}" == false && "${RUN_UI}" == false ]]; then
  RUN_UNIT=true
  RUN_INTEGRATION=true
  RUN_UI=true
fi

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1"
    exit 1
  fi
}

prepare_simulator() {
  if [[ -n "${SIMULATOR_UDID}" ]]; then
    return
  fi

  echo "Preparing iOS simulator: ${IOS_SIMULATOR_DEVICE}"
  local output_file
  output_file="$(mktemp)"

  GITHUB_OUTPUT="${output_file}" \
    IOS_SIMULATOR_DEVICE="${IOS_SIMULATOR_DEVICE}" \
    "${ROOT_DIR}/.github/workflows/scripts/prepare-ios-simulator.sh"

  SIMULATOR_UDID="$(awk -F= '/^udid=/{ print $2 }' "${output_file}" | tail -n 1)"
  rm -f "${output_file}"

  if [[ -z "${SIMULATOR_UDID}" ]]; then
    echo "Failed to resolve simulator UDID for ${IOS_SIMULATOR_DEVICE}."
    exit 1
  fi
}

run_xcodebuild() {
  local log_path="$1"
  shift

  rm -f "${log_path}"

  if command -v xcpretty >/dev/null 2>&1; then
    "$@" | tee "${log_path}" | xcpretty --test --color --simple
  else
    echo "xcpretty is not installed; writing raw xcodebuild output."
    "$@" | tee "${log_path}"
  fi
}

wait_for_emulator() {
  local attempt=1
  local max_attempts=60

  while [[ "${attempt}" -le "${max_attempts}" ]]; do
    if curl --output /dev/null --silent --fail http://localhost:9099; then
      sleep 15
      if curl --output /dev/null --silent --fail http://localhost:9099; then
        echo "Firebase Auth emulator is online."
        return
      fi
    fi

    echo "Waiting for Firebase Auth emulator, check ${attempt} of ${max_attempts}..."
    sleep 1
    attempt=$((attempt + 1))
  done

  echo "Firebase Auth emulator did not come online."
  return 1
}

start_emulator_if_needed() {
  if curl --output /dev/null --silent --fail http://localhost:9099; then
    echo "Using existing Firebase Auth emulator on localhost:9099."
    return
  fi

  require_command firebase
  require_command node
  require_command npm

  local retry=1
  local max_retries=3

  while [[ "${retry}" -le "${max_retries}" ]]; do
    echo "Starting Firebase Auth emulator, try ${retry} of ${max_retries}..."
    pushd "${ROOT_DIR}/e2eTest/FirebaseSwiftUIExample/FirebaseSwiftUIExample" >/dev/null
    firebase emulators:start --only auth --project flutterfire-e2e-tests --debug > firebase-debug.log 2>&1 &
    EMULATOR_PID="$!"
    popd >/dev/null

    if wait_for_emulator; then
      return
    fi

    if kill -0 "${EMULATOR_PID}" 2>/dev/null; then
      kill "${EMULATOR_PID}" 2>/dev/null || true
      wait "${EMULATOR_PID}" 2>/dev/null || true
    fi
    EMULATOR_PID=""
    retry=$((retry + 1))
  done

  echo "Firebase Auth emulator did not come online after ${max_retries} attempts."
  exit 1
}

run_lint() {
  echo "Running Swift format lint..."
  bash "${ROOT_DIR}/lint-swift.sh"
}

run_unit_tests() {
  echo "Running FirebaseSwiftUI package unit tests..."
  prepare_simulator
  rm -rf "${ROOT_DIR}/FirebaseSwiftUIPackageTests.xcresult"

  pushd "${ROOT_DIR}" >/dev/null
  run_xcodebuild "${ROOT_DIR}/FirebaseSwiftUIPackageTests.log" \
    xcodebuild test \
      -scheme FirebaseUI-Package \
      -destination "id=${SIMULATOR_UDID}" \
      -enableCodeCoverage YES \
      -resultBundlePath FirebaseSwiftUIPackageTests.xcresult
  popd >/dev/null
}

run_integration_tests() {
  echo "Running FirebaseSwiftUIExample integration tests..."
  start_emulator_if_needed
  prepare_simulator
  rm -rf "${ROOT_DIR}/e2eTest/FirebaseSwiftUIExample/FirebaseSwiftUIExampleTests.xcresult"

  pushd "${ROOT_DIR}/e2eTest/FirebaseSwiftUIExample" >/dev/null
  run_xcodebuild "${ROOT_DIR}/e2eTest/FirebaseSwiftUIExample/FirebaseSwiftUIExampleTests.log" \
    xcodebuild test \
      -scheme FirebaseSwiftUIExampleTests \
      -destination "id=${SIMULATOR_UDID}" \
      -parallel-testing-enabled NO \
      -enableCodeCoverage YES \
      -resultBundlePath FirebaseSwiftUIExampleTests.xcresult
  popd >/dev/null
}

run_ui_tests() {
  echo "Running FirebaseSwiftUIExample UI tests..."
  start_emulator_if_needed
  prepare_simulator
  rm -rf "${ROOT_DIR}/e2eTest/FirebaseSwiftUIExample/FirebaseSwiftUIExampleUITests.xcresult"

  pushd "${ROOT_DIR}/e2eTest/FirebaseSwiftUIExample" >/dev/null
  run_xcodebuild "${ROOT_DIR}/e2eTest/FirebaseSwiftUIExample/FirebaseSwiftUIExampleUITests-build.log" \
    xcodebuild build-for-testing \
      -scheme FirebaseSwiftUIExampleUITests \
      -destination "id=${SIMULATOR_UDID}" \
      -enableCodeCoverage YES

  run_xcodebuild "${ROOT_DIR}/e2eTest/FirebaseSwiftUIExample/FirebaseSwiftUIExampleUITests.log" \
    xcodebuild test-without-building \
      -scheme FirebaseSwiftUIExampleUITests \
      -destination "id=${SIMULATOR_UDID}" \
      -parallel-testing-enabled NO \
      -enableCodeCoverage YES \
      -resultBundlePath FirebaseSwiftUIExampleUITests.xcresult
  popd >/dev/null
}

require_command xcodebuild
require_command xcrun
require_command awk
require_command curl

if [[ "${RUN_LINT}" == true ]]; then
  run_lint
fi

if [[ "${RUN_UNIT}" == true ]]; then
  run_unit_tests
fi

if [[ "${RUN_INTEGRATION}" == true ]]; then
  run_integration_tests
fi

if [[ "${RUN_UI}" == true ]]; then
  run_ui_tests
fi

echo "SwiftUI Auth checks completed successfully."
