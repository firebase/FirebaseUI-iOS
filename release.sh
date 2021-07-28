#!/usr/bin/env bash

set -euxo pipefail

pod spec lint FirebaseDatabaseUI.podspec && \
  pod spec lint FirebaseAuthUI.podspec && \
  pod spec lint FirebaseStorageUI.podspec && \
  pod spec lint FirebaseFirestoreUI.podspec

pod trunk push FirebaseDatabaseUI.podspec && \
  pod trunk push FirebaseAuthUI.podspec && \
  pod trunk push FirebaseStorageUI.podspec && \
  pod trunk push FirebaseFirestoreUI.podspec

pod spec lint FirebaseAnonymousAuthUI.podspec && \
  pod spec lint FirebaseEmailAuthUI.podspec && \
  pod spec lint FirebaseFacebookAuthUI.podspec && \
  pod spec lint FirebaseGoogleAuthUI.podspec && \
  pod spec lint FirebaseOAuthUI.podspec && \
  pod spec lint FirebasePhoneAuthUI.podspec

pod trunk push FirebaseAnonymousAuthUI.podspec && \
  pod trunk push FirebaseEmailAuthUI.podspec && \
  pod trunk push FirebaseFacebookAuthUI.podspec && \
  pod trunk push FirebaseGoogleAuthUI.podspec && \
  pod trunk push FirebaseOAuthUI.podspec && \
  pod trunk push FirebasePhoneAuthUI.podspec

pod spec lint FirebaseUI.podspec && \
  pod trunk push FirebaseUI.podspec
