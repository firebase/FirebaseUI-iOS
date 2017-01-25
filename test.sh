#!/usr/bin/env bash

set -o pipefail && xcodebuild \
  -workspace FirebaseUI.xcworkspace \
  -scheme FirebaseUI \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 7' \
  build \
  test \
  ONLY_ACTIVE_ARCH=YES \
  CODE_SIGNING_REQUIRED=NO\
  | xcpretty
