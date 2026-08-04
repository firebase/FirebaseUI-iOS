---
type: Reference
title: SPM and CocoaPods dual distribution workflow
description: Durable rules for Swift Package Manager vs CocoaPods products, source ownership, and release scripts.
tags: [spm, cocoapods, packaging, distribution, workflow]
timestamp: 2026-07-31T00:00:00Z
---

# SPM and CocoaPods dual distribution workflow

FirebaseUI-iOS ships **two consumer distribution channels** with different product sets. Agents must not assume "one install story" for the whole monorepo.

Ephemeral tracking: [SPM / CocoaPods work queue](spm-cocoapods-work-queue.md). Policy for queues: [documentation policy](../documentation-policy.md).

## Product matrix

| Product | Consumer path | Sources | Min iOS (approx.) |
|---------|---------------|---------|-------------------|
| `FirebaseAuthSwiftUI` + provider libs (`FirebaseGoogleSwiftUI`, `FirebaseFacebookSwiftUI`, `FirebasePhoneAuthSwiftUI`, `FirebaseAppleSwiftUI`, `FirebaseTwitterSwiftUI`, `FirebaseOAuthSwiftUI`) | **SPM only** (`Package.swift`) | `FirebaseSwiftUI/**` | iOS 17+ (package platforms) |
| `FirebaseAuthUIComponents` | SPM product (shared UI components for Auth) | `FirebaseSwiftUI/FirebaseAuthUIComponents` | iOS 17+ |
| `FirebaseDatabaseUI` | CocoaPods (`FirebaseDatabaseUI.podspec` / `FirebaseUI/Database`) **and** SPM product | `FirebaseDatabaseUI/Sources` | Pods historically iOS 13+; SPM package platforms iOS 17+ |
| `FirebaseFirestoreUI` | CocoaPods + SPM product | `FirebaseFirestoreUI/Sources` | same dual note |
| `FirebaseStorageUI` | CocoaPods + SPM product | `FirebaseStorageUI/Sources` | same dual note |
| `FirebaseStorageUISwift` | **SPM product** (Swift bridge; depends on `FirebaseStorageUI`) | `FirebaseStorageUI/SwiftBridge` | iOS 17+ (package platforms) |
| Umbrella `FirebaseUI` pod | CocoaPods only (`FirebaseUI.podspec` subspecs) | header umbrella + subspec deps | see podspec |

Canonical consumer docs: [`README.md`](../../README.md), [`GETTING_STARTED.md`](../../GETTING_STARTED.md), [`FirebaseSwiftUI/README.md`](../../FirebaseSwiftUI/README.md).

## Rules

1. **SwiftUI Auth is SPM-first.** Do not add CocoaPods subspecs for `FirebaseAuthSwiftUI` / provider packages unless durable docs and CI are updated in the same change.
2. **UIKit data-binding modules are dual-built.** Edits under `Firebase*UI/Sources` must keep CocoaPods tests and SPM scheme builds green ([distribution path gate](../testing/running-tests.md#distribution-path-gate-blocking)).
3. **One source tree per module.** Do not fork SPM-only copies of UIKit sources; `Package.swift` targets point at the same `Sources` directories as the pods.
4. **Versioning is split operationally:**
   - CocoaPods / umbrella: [`release.sh`](../../release.sh), [`staging.sh`](../../staging.sh), podspecs
   - SwiftUI Auth package version stamp: [`release-swift.sh`](../../release-swift.sh) updates `FirebaseSwiftUI/FirebaseAuthSwiftUI/Sources/Version.swift` (human-driven; agents need explicit user request)
5. **Swift language mode:** SwiftUI Auth targets set `.swiftLanguageMode(.v6)` in `Package.swift`. Do not silently relax to silence concurrency errors — fix or record an accepted exception.

## `Package.swift` ownership

- Tools version / package name: `FirebaseUI`
- Platforms: `.iOS(.v17)`
- UIKit SPM targets use ObjC `publicHeadersPath` + header search paths — preserve these when moving files
- Storage exposes both `FirebaseStorageUI` (ObjC product) and `FirebaseStorageUISwift` (Swift bridge **product**)

## CocoaPods ownership

- Per-module podspecs at repo root: `FirebaseDatabaseUI.podspec`, `FirebaseFirestoreUI.podspec`, `FirebaseStorageUI.podspec`, umbrella `FirebaseUI.podspec`
- Module `Podfile`s under each `Firebase*UI/` directory drive local test workspaces
- Prefer `bundle exec` with repo [`Gemfile`](../../Gemfile)

## Decision log (durable)

| ID | Decision | Status |
|----|----------|--------|
| Dist-AD-1 | SwiftUI Auth ships via SPM; UIKit Database/Firestore/Storage remain CocoaPods-supported and SPM-listed | Accepted |
| Dist-AD-2 | Shared UIKit sources must pass both CocoaPods `./test.sh` and CI SPM scheme jobs when changed | Accepted |
| Dist-AD-3 | Agents do not run trunk/release scripts without explicit user request | Accepted |

New distribution decisions get a row here; active migration tasks go in the [work queue](spm-cocoapods-work-queue.md).
