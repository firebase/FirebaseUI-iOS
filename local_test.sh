#!/usr/bin/env bash

set -euxo pipefail

EXIT_STATUS=0

schemes=( "FirebaseDatabaseUI" "FirebaseFirestoreUI" "FirebaseStorageUI" )

bundle exec pod repo update;

for ((i=0; i<${#schemes[*]}; i++));
do
  cd ${schemes[i]};
  bundle exec pod install;
  (xcodebuild \
    -workspace "${schemes[i]}.xcworkspace" \
    -scheme "${schemes[i]}" \
    -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,OS=latest,name=iPhone 16 Pro' \
    clean build test \
    ONLY_ACTIVE_ARCH=YES \
    | xcpretty) || EXIT_STATUS=$?;
  bundle exec pod deintegrate;
  cd ..;
done

exit $EXIT_STATUS
