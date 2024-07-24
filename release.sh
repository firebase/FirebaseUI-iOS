#!/usr/bin/env bash

set -euxo pipefail

pod spec lint FirebaseDatabaseUI.podspec && \
  pod spec lint --allow-warnings FirebaseAuthUI.podspec && \
  pod spec lint FirebaseStorageUI.podspec && \
  pod spec lint FirebaseFirestoreUI.podspec

pod trunk push FirebaseDatabaseUI.podspec && \
  pod trunk push --allow-warnings FirebaseAuthUI.podspec && \
  pod trunk push FirebaseStorageUI.podspec && \
  pod trunk push FirebaseFirestoreUI.podspec

pod spec lint FirebaseAnonymousAuthUI.podspec && \
  pod spec lint --allow-warnings FirebaseEmailAuthUI.podspec && \
  pod spec lint FirebaseFacebookAuthUI.podspec && \
  pod spec lint FirebaseGoogleAuthUI.podspec && \
  pod spec lint FirebaseOAuthUI.podspec && \
  pod spec lint --allow-warnings FirebasePhoneAuthUI.podspec

pod trunk push FirebaseAnonymousAuthUI.podspec && \
  pod trunk push --allow-warnings FirebaseEmailAuthUI.podspec && \
  pod trunk push FirebaseFacebookAuthUI.podspec && \
  pod trunk push FirebaseGoogleAuthUI.podspec && \
  pod trunk push FirebaseOAuthUI.podspec && \
  pod trunk push --allow-warnings FirebasePhoneAuthUI.podspec

pod spec lint FirebaseUI.podspec && \
  pod trunk push FirebaseUI.podspec
