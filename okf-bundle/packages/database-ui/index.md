---
type: Reference
title: FirebaseDatabaseUI package notes
description: Agent reference for Realtime Database UIKit bindings.
tags: [database, uikit, cocoapods, spm]
timestamp: 2026-07-31T00:00:00Z
---

# Database UI

CocoaPods: `FirebaseDatabaseUI` / `FirebaseUI/Database`. SPM product: `FirebaseDatabaseUI`.

## Layout

| Path | Role |
|------|------|
| `FirebaseDatabaseUI/Sources/` | ObjC implementation + public headers |
| `FirebaseDatabaseUI/FirebaseDatabaseUITests/` | XCTest (array/data source behavior) |
| `FirebaseDatabaseUI/Podfile` | Local workspace deps (`Firebase/Database`) |
| `FirebaseDatabaseUI.podspec` | CocoaPods publish metadata |
| `FirebaseDatabaseUI/README.md` | User-facing API overview |

Key types: `FUIArray`, `FUISortedArray`, `FUIIndexArray`, `FUITableViewDataSource`, `FUICollectionViewDataSource`, index variants — see module README.

## Validation

```bash
cd FirebaseDatabaseUI && bundle exec pod install && cd ..
./test.sh FirebaseDatabaseUI
xcodebuild -scheme FirebaseDatabaseUI -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,OS=latest,name=iPhone 17 Pro'
bundle exec pod lib lint FirebaseDatabaseUI.podspec   # when podspec/packaging changes
```

CI: [uikit-modules CI](../../ci-workflows/uikit-modules.md). Distribution: [SPM and CocoaPods workflow](../../packaging/spm-and-cocoapods-workflow.md).

## Agent notes

* Array/data-source updates are concurrency-sensitive (batch updates vs Firebase child events). Prefer regression tests in `FirebaseDatabaseUITests` when touching `FUIArray` / collection data sources.
* Keep SPM header search paths / `publicHeadersPath` intact when moving headers (`Package.swift` target settings).
* Do not "fix" desyncs by skipping UI updates without tests — recent history includes desync crash fixes that require lockstep item/UI updates.
