#!/usr/bin/env bash

set -eo pipefail

EXIT_STATUS=0

folders=( "AnonymousAuth" "Auth" "Database" "EmailAuth" "FacebookAuth" \
    "Firestore" "GoogleAuth" "PhoneAuth" "Storage" )

schemes=( "FirebaseAnonymousAuthUI" "FirebaseAuthUI" "FirebaseDatabaseUI" \
    "FirebaseEmailAuthUI" "FirebaseFacebookAuthUI" "FirebaseFirestoreUI" \
    "FirebaseGoogleAuthUI" "FirebasePhoneAuthUI" "FirebaseStorageUI" )

pod repo update;

for ((i=0; i<${#folders[*]}; i++));
do
  cd ${folders[i]};
  pod install;
  (xcodebuild \
    -workspace ${schemes[i]}.xcworkspace \
    -scheme ${schemes[i]} \
    -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,OS=12.2,name=iPhone XS' \
    build \
    test \
    ONLY_ACTIVE_ARCH=YES \
    | xcpretty) || EXIT_STATUS=$?;
  pod deintegrate;
  cd ..;
done
