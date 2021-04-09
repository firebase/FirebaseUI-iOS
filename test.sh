#!/usr/bin/env bash

set -euxo pipefail

EXIT_STATUS=0

schemes=( "FirebaseAnonymousAuthUI" "FirebaseAuthUI" "FirebaseDatabaseUI" \
    "FirebaseEmailAuthUI" "FirebaseFacebookAuthUI" "FirebaseFirestoreUI" \
    "FirebaseGoogleAuthUI" "FirebaseOAuthUI" "FirebasePhoneAuthUI" "FirebaseStorageUI" )

pod repo update;

for ((i=0; i<${#schemes[*]}; i++));
do
  cd ${schemes[i]};
  pod install;
  (xcodebuild \
    -workspace ${schemes[i]}.xcworkspace \
    -scheme ${schemes[i]} \
    -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,OS=latest,name=iPhone 11 Pro' \
    build \
    test \
    ONLY_ACTIVE_ARCH=YES \
    | xcpretty) || EXIT_STATUS=$?;
  pod deintegrate;
  cd ..;
done

exit $EXIT_STATUS
