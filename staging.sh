#!/usr/bin/env bash

set -euxo pipefail

pod repo push --use-json spec-staging FirebaseDatabaseUI.podspec && \
  pod repo push --use-json --allow-warnings spec-staging FirebaseAuthUI.podspec && \
  pod repo push --use-json spec-staging FirebaseStorageUI.podspec && \
  pod repo push --use-json spec-staging FirebaseFirestoreUI.podspec

pod repo push --use-json spec-staging FirebaseAnonymousAuthUI.podspec && \
  pod repo push --use-json --allow-warnings spec-staging FirebaseEmailAuthUI.podspec && \
  pod repo push --use-json spec-staging FirebaseFacebookAuthUI.podspec && \
  pod repo push --use-json spec-staging FirebaseGoogleAuthUI.podspec && \
  pod repo push --use-json spec-staging FirebaseOAuthUI.podspec && \
  pod repo push --use-json --allow-warnings spec-staging FirebasePhoneAuthUI.podspec

pod spec lint FirebaseUI.podspec && \
  pod repo push --use-json spec-staging FirebaseUI.podspec
