#!/usr/bin/env bash

set -euxo pipefail

pod repo push --use-json spec-staging FirebaseDatabaseUI.podspec && \
  pod repo push --use-json spec-staging FirebaseStorageUI.podspec && \
  pod repo push --use-json spec-staging FirebaseFirestoreUI.podspec

pod spec lint FirebaseUI.podspec && \
  pod repo push --use-json spec-staging FirebaseUI.podspec
