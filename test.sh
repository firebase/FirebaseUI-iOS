#!/usr/bin/env bash

set -euxo pipefail

EXIT_STATUS=0

folders=( "AnonymousAuth" "OAuth" "PhoneAuth" "Storage" )

schemes=( "FirebaseAnonymousAuthUI" "FirebaseOAuthUI" "FirebasePhoneAuthUI" "FirebaseStorageUI" )

pod repo update;

for ((i=0; i<${#folders[*]}; i++));
do
  cd ${folders[i]};
  pod install;
  (xcodebuild \
    -workspace ${schemes[i]}.xcworkspace \
    -scheme ${schemes[i]} \
    -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,OS=13.3,name=iPhone 11 Pro' \
    build \
    test \
    ONLY_ACTIVE_ARCH=YES \
    | xcpretty) || EXIT_STATUS=$?;
  pod deintegrate;
  cd ..;
done

exit $EXIT_STATUS
