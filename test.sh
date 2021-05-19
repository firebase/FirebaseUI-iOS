#!/usr/bin/env bash

set -euxo pipefail

EXIT_STATUS=0

module_name="$1"

pushd "$module_name";
bundle exec pod install;
(xcodebuild \
  -workspace "$module_name.xcworkspace" \
  -scheme "$module_name" \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,OS=latest,name=iPhone 11 Pro' \
  clean build test \
  ONLY_ACTIVE_ARCH=YES \
  | xcpretty) || EXIT_STATUS=$?;
bundle exec pod deintegrate;
popd;

exit $EXIT_STATUS
