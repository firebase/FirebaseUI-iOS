#!/usr/bin/env bash

set -euxo pipefail

pod spec lint FirebaseDatabaseUI.podspec && \
  pod spec lint FirebaseStorageUI.podspec && \
  pod spec lint FirebaseFirestoreUI.podspec

pod trunk push FirebaseDatabaseUI.podspec && \
  pod trunk push FirebaseStorageUI.podspec && \
  pod trunk push FirebaseFirestoreUI.podspec

pod spec lint FirebaseUI.podspec && \
  pod trunk push FirebaseUI.podspec
