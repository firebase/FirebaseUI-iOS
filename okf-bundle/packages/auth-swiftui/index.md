---
type: Reference
title: FirebaseAuthSwiftUI package notes
description: Agent reference for SwiftUI Auth core and provider packages.
tags: [auth, swiftui, spm]
timestamp: 2026-07-31T00:00:00Z
---

# Auth SwiftUI

SPM products: `FirebaseAuthSwiftUI`, `FirebaseAuthUIComponents`, `FirebaseGoogleSwiftUI`, `FirebaseFacebookSwiftUI`, `FirebasePhoneAuthSwiftUI`, `FirebaseAppleSwiftUI`, `FirebaseTwitterSwiftUI`, `FirebaseOAuthSwiftUI`.

## Layout

| Path | Role |
|------|------|
| `FirebaseSwiftUI/FirebaseAuthSwiftUI/` | Core Auth UI (`AuthService`, flows, strings); package unit tests under `Tests/` |
| `FirebaseSwiftUI/FirebaseAuthUIComponents/` | Shared UI components/resources |
| `FirebaseSwiftUI/Firebase*SwiftUI/` | Provider packages + their `Tests/` |
| `e2eTest/FirebaseSwiftUIExample/` | Integration + UI test host app |
| `samples/swiftui/FirebaseSwiftUISample/` | Manual/sample app |
| `GETTING_STARTED.md` / `FirebaseSwiftUI/README.md` | User-facing docs |

## Validation

| Intent | Command |
|--------|---------|
| Lint | `./lint-swift.sh` |
| Package unit | `./swiftui-tests.sh --unit` |
| Integration / UI | `./swiftui-tests.sh --integration` / `--ui` |
| Area / pre-merge | `./swiftui-tests.sh --lint --all` |

Allowlist: [agent command policy](../../testing/agent-command-policy.md). Detail: [running tests](../../testing/running-tests.md#swiftui-auth-tests). Emulator project: [firebase testing project](../../testing/firebase-testing-project.md). CI: [swiftui-auth CI](../../ci-workflows/swiftui-auth.md).

## Agent notes

* Swift 6 language mode is set on these targets in `Package.swift` — treat concurrency/isolation errors as product issues.
* Provider packages depend on `FirebaseAuthSwiftUI` + `FirebaseAuthUIComponents`; keep public Auth configuration APIs stable unless versioning intentionally.
* Version stamp for Swift releases: `FirebaseSwiftUI/FirebaseAuthSwiftUI/Sources/Version.swift` via [`release-swift.sh`](../../../release-swift.sh) (human release process).
* Feature parity with FirebaseUI-Android Auth UI where applicable ([`CONTRIBUTING.md`](../../../CONTRIBUTING.md)).
* Emulator-backed tests use project `flutterfire-e2e-tests` by default.

## Related

* [SPM and CocoaPods workflow](../../packaging/spm-and-cocoapods-workflow.md) — Auth is SPM-only for consumers
* [`.agents/skills/firebaseui-ios-getting-started/SKILL.md`](../../../.agents/skills/firebaseui-ios-getting-started/SKILL.md) — getting-started skill (user docs adjacent)
