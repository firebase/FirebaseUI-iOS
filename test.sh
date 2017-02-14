#!/usr/bin/env bash

set -eo pipefail

EXIT_STATUS=0

(xcodebuild \
  -workspace FirebaseUI.xcworkspace \
  -scheme FirebaseUI \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 7' \
  build \
  test \
  ONLY_ACTIVE_ARCH=YES \
  CODE_SIGNING_REQUIRED=NO \
  | xcpretty) || EXIT_STATUS=$?

cd samples/objc || EXIT_STATUS=$?
pod install || EXIT_STATUS=$?

(xcodebuild \
  -workspace FirebaseUI-demo-objc.xcworkspace \
  -scheme FirebaseUI-demo-objc \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 7' \
  build \
  ONLY_ACTIVE_ARCH=YES \
  CODE_SIGNING_REQUIRED=NO \
  | xcpretty) || EXIT_STATUS=$?

exit $EXIT_STATUS
