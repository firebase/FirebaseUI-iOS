---
type: Reference
title: FirebaseStorageUI package notes
description: Agent reference for Storage UIKit bindings and Swift bridge.
tags: [storage, uikit, cocoapods, spm, sdwebimage]
timestamp: 2026-07-31T00:00:00Z
---

# Storage UI

CocoaPods: `FirebaseStorageUI` / `FirebaseUI/Storage`. SPM products: `FirebaseStorageUI`, `FirebaseStorageUISwift`.

## Layout

| Path | Role |
|------|------|
| `FirebaseStorageUI/Sources/` | ObjC UIImageView categories, Storage download integration, SDWebImage hooks |
| `FirebaseStorageUI/SwiftBridge/` | Sources for the `FirebaseStorageUISwift` SPM product |
| `FirebaseStorageUI/FirebaseStorageUITests/` | XCTest |
| `FirebaseStorageUI/Podfile` | Local workspace deps |
| `FirebaseStorageUI.podspec` | CocoaPods publish metadata |
| `FirebaseStorageUI/README.md` | User-facing API overview |

Depends on Firebase Storage + **SDWebImage** (see `Package.swift` / podspec).

## Validation

```bash
cd FirebaseStorageUI && bundle exec pod install && cd ..
./test.sh FirebaseStorageUI
xcodebuild -scheme FirebaseStorageUI -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,OS=latest,name=iPhone 17 Pro'
bundle exec pod lib lint FirebaseStorageUI.podspec   # when podspec/packaging changes
```

CI: [uikit-modules CI](../../ci-workflows/uikit-modules.md). Distribution: [SPM and CocoaPods workflow](../../packaging/spm-and-cocoapods-workflow.md).

## Agent notes

* `FirebaseStorageUISwift` is a published SPM **product** (not an internal-only target) — update the Swift bridge when changing the public Swift surface for SPM consumers.
* SDWebImage integration and `FIRStorageDownloadTask` categories are load-bearing; add tests under `FirebaseStorageUITests` when changing download/image loader behavior.
* Dual-distribution gate applies to `Sources/` the same as Database/Firestore.
