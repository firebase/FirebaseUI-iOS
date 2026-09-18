---
type: Reference
title: FirebaseFirestoreUI package notes
description: Agent reference for Firestore UIKit bindings.
tags: [firestore, uikit, cocoapods, spm]
timestamp: 2026-07-31T00:00:00Z
---

# Firestore UI

CocoaPods: `FirebaseFirestoreUI` / `FirebaseUI/Firestore`. SPM product: `FirebaseFirestoreUI`.

## Layout

| Path | Role |
|------|------|
| `FirebaseFirestoreUI/Sources/` | ObjC implementation + public headers |
| `FirebaseFirestoreUI/FirebaseFirestoreUITests/` | XCTest |
| `FirebaseFirestoreUI/Podfile` | Local workspace deps |
| `FirebaseFirestoreUI.podspec` | CocoaPods publish metadata |
| `FirebaseFirestoreUI/README.md` | User-facing API overview |

## Validation

```bash
cd FirebaseFirestoreUI && bundle exec pod install && cd ..
./test.sh FirebaseFirestoreUI
xcodebuild -scheme FirebaseFirestoreUI -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,OS=latest,name=iPhone 17 Pro'
bundle exec pod lib lint FirebaseFirestoreUI.podspec   # when podspec/packaging changes
```

CI: [uikit-modules CI](../../ci-workflows/uikit-modules.md). Distribution: [SPM and CocoaPods workflow](../../packaging/spm-and-cocoapods-workflow.md).

## Agent notes

* Same dual-distribution rules as Database UI — CocoaPods test path + SPM scheme when shared sources change.
* Preserve public header layout for both podspec `source_files` / header maps and SPM `publicHeadersPath`.
