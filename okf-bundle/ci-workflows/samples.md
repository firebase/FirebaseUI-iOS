---
type: Reference
title: Samples CI
description: Job shape for .github/workflows/sample.yml.
tags: [ci, samples]
timestamp: 2026-07-31T00:00:00Z
---

# Samples CI

Workflow: [`.github/workflows/sample.yml`](../../.github/workflows/sample.yml).

## Jobs

| Job | Area | Notes |
|-----|------|-------|
| `swiftui` | `samples/swiftui/FirebaseSwiftUISample` | `xcodebuild` **build**; destination `iPhone 17` |
| `swift` | `samples/swift` (`FirebaseUI-demo-swift`) | CocoaPods install then `xcodebuild` **`clean build test`**; destination `iPhone 17 Pro` |
| `objc` | `samples/objc` (`FirebaseUI-demo-objc`) | CocoaPods install then `xcodebuild` **`clean build`**; destination `iPhone 17 Pro` |

Copy **exact** `xcodebuild` / `pod` steps from the workflow when validating sample changes locally — [running tests § samples](../testing/running-tests.md#sample-builds).

Samples are CI smoke checks for the demo apps (the Swift UIKit sample also runs its test target). They are not a substitute for `./swiftui-tests.sh` or `./test.sh`.
