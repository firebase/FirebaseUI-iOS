# CI workflows

GitHub Actions job map for FirebaseUI-iOS. Local command ownership stays in [agent command policy](../testing/agent-command-policy.md) and [running tests](../testing/running-tests.md).

## Workflows

| Workflow | Path | Purpose |
|----------|------|---------|
| SwiftUI Auth | [`swiftui-auth.yml`](../../.github/workflows/swiftui-auth.yml) | SwiftFormat check, SPM package unit tests, integration + UI tests with Auth emulator |
| Database | [`database.yml`](../../.github/workflows/database.yml) | CocoaPods `xcodebuild` test, SPM scheme build, `pod lib lint` |
| Firestore | [`firestore.yml`](../../.github/workflows/firestore.yml) | Same shape as Database for Firestore UI |
| Storage | [`storage.yml`](../../.github/workflows/storage.yml) | Same shape as Database for Storage UI |
| Samples | [`sample.yml`](../../.github/workflows/sample.yml) | Build SwiftUI + UIKit sample apps |
| Issue labels / stale | [`issue-labels.yml`](../../.github/workflows/issue-labels.yml), [`stale-issue.yml`](../../.github/workflows/stale-issue.yml) | Repo hygiene (not product validation) |

## Detail docs

* [SwiftUI Auth CI](swiftui-auth.md) — jobs, Xcode pin, emulator, artifacts
* [UIKit modules CI](uikit-modules.md) — Database / Firestore / Storage job matrix
* [Samples CI](samples.md) — sample build destinations

## Shared pins (as of authoring)

* **Xcode 26.2** selected in module/sample/SwiftUI workflows
* **Simulator:** `iPhone 17 Pro` for most test jobs; SwiftUI sample build uses `iPhone 17`
* **Simulator prep script:** [`.github/workflows/scripts/prepare-ios-simulator.sh`](../../.github/workflows/scripts/prepare-ios-simulator.sh)

When pins drift, update these OKF docs in the same change that updates CI — do not leave agents on stale device/Xcode names.
