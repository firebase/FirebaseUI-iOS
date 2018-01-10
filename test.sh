#!/usr/bin/env bash

set -eo pipefail

EXIT_STATUS=0

(xcodebuild \
  -workspace FirebaseUI.xcworkspace \
  -scheme FirebaseUI \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,OS=11.2,name=iPhone X' \
  build \
  test \
  ONLY_ACTIVE_ARCH=YES \
  CODE_SIGNING_REQUIRED=NO \
  | xcpretty) || EXIT_STATUS=$?

# It'd be nice to test building the objc sample as a simple
# integration test, but we don't have a GoogleService-Info.plist file
# on Travis.
# cd samples/objc
# pod install

# (xcodebuild \
#   -workspace FirebaseUI-demo-objc.xcworkspace \
#   -scheme FirebaseUI-demo-objc \
#   -sdk iphonesimulator \
#   -destination 'platform=iOS Simulator,name=iPhone 7' \
#   build \
#   ONLY_ACTIVE_ARCH=YES \
#   CODE_SIGNING_REQUIRED=NO \
#   | xcpretty) || EXIT_STATUS=$?

exit $EXIT_STATUS
