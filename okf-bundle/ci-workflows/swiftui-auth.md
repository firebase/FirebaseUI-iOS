---
type: Reference
title: SwiftUI Auth CI
description: Job shape and triage notes for .github/workflows/swiftui-auth.yml.
tags: [ci, swiftui, auth, emulator]
timestamp: 2026-07-31T00:00:00Z
---

# SwiftUI Auth CI

Workflow: [`.github/workflows/swiftui-auth.yml`](../../.github/workflows/swiftui-auth.yml).

Local mirror: [`./swiftui-tests.sh`](../../swiftui-tests.sh) — [running tests](../testing/running-tests.md#swiftui-auth-tests). Emulator defaults: [firebase testing project](../testing/firebase-testing-project.md).

## Jobs

| Job | What | Notes |
|-----|------|-------|
| `format-check` | `brew install swiftformat` + `./lint-swift.sh` | Paths in `lint-swift.sh` |
| `unit-tests` | `xcodebuild test -scheme FirebaseUI-Package` on prepared simulator | Coverage on; uploads log/xcresult on failure |
| `integration-tests` | Auth emulator + `FirebaseSwiftUIExampleTests` | Node 20, Java 17, `firebase-tools`; `parallel-testing-enabled NO` |
| `ui-tests` | Auth emulator + `build-for-testing` / `test-without-building` for `FirebaseSwiftUIExampleUITests` | Same emulator setup; uploads emulator debug log on failure |

## Environment

| Variable / pin | Value |
|----------------|-------|
| `XCODE_VERSION` | `26.2` |
| `IOS_SIMULATOR_DEVICE` | `iPhone 17 Pro` |
| Runner | `macos-26` |
| Emulator project (script default) | `flutterfire-e2e-tests` |
| Emulator port probe | `http://localhost:9099` |

## Path filters

PRs/pushes run when `FirebaseSwiftUI/**`, `samples/swiftui/**`, `e2eTest/**`, `Package.swift`, `Package.resolved`, Gemfile, or this workflow change.

## Triage

1. Prefer downloading failure artifacts (logs / `.xcresult` / `firebase-debug.log`) over re-running blind.
2. Format failures → `./format-swift.sh` then `./lint-swift.sh`.
3. Emulator failures → confirm Firebase CLI, port `9099`, and project id; locally use `./swiftui-tests.sh --integration`.
4. Simulator resolution failures → inspect `prepare-ios-simulator.sh` output and `xcrun simctl list devices available`.
