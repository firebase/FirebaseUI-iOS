#!/usr/bin/env bash

set -euxo pipefail

EXIT_STATUS=0

module_name="$1"

pushd "$module_name";
(xcodebuild \
  -workspace "$module_name.xcworkspace" \
  -scheme "$module_name" \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,OS=latest,name=iPhone 13 Pro' \
  clean build test \
  ONLY_ACTIVE_ARCH=YES \
  | xcpretty) || EXIT_STATUS=$?;
popd;

exit $EXIT_STATUS
