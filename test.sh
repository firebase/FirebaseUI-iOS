#!/usr/bin/env bash

set -eo pipefail

EXIT_STATUS=0

folders=( "AnonymousAuth" "Auth" "Database" "EmailAuth" "FacebookAuth" \
    "Firestore" "GoogleAuth" "PhoneAuth" "Storage" "TwitterAuth" "UITests" )

schemes=( "FirebaseAnonymousAuthUI" "FirebaseAuthUI" "FirebaseDatabaseUI" \
    "FirebaseEmailAuthUI" "FirebaseFacebookAuthUI" "FirebaseFirestoreUI" \
    "FirebaseGoogleAuthUI" "FirebasePhoneAuthUI" "FirebaseStorageUI" \
    "FirebaseTwitterAuthUI" "FirebaseUISample")

pod repo update;

for ((i=0; i<${#folders[*]}; i++));
do
  cd ${folders[i]};
  pod install >/dev/null;
  (xcodebuild \
    -workspace ${schemes[i]}.xcworkspace \
    -scheme ${schemes[i]} \
    -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,OS=12.1,name=iPhone XS' \
    build \
    test \
    ONLY_ACTIVE_ARCH=YES \
    | xcpretty) || EXIT_STATUS=$?;
  pod deintegrate >/dev/null;
  cd ..;
done
