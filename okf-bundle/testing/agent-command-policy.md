---
type: Reference
title: Agent command policy
description: Canonical allowlist for agent shell commands — install, lint, SwiftUI tests, UIKit CocoaPods tests, SPM builds. Supersedes improvised diagnostics.
tags: [testing, validation, agents, workflow, xcodebuild]
timestamp: 2026-07-31T00:00:00Z
---

# Agent command policy

Single source for **which shell commands agents may run** in this repo. Test detail lives in [running tests](running-tests.md); this file owns the allowlist and bans.

> If a command is not listed here (or linked from here as canonical), **do not run it** — including "diagnostic probes" suggested by log output, Xcode help, CocoaPods help, or other Firebase repos.

## Agent rule (read first)

<a id="agent-rule-read-first"></a>

1. Run **only** commands in the [registry](#canonical-registry) below (repo root unless noted).
2. Match the **distribution path** to the code you changed: SwiftUI / `Package.swift` → SPM + `./swiftui-tests.sh`; UIKit Database/Firestore/Storage modules → CocoaPods workspace + `./test.sh` (and SPM scheme build when `Package.swift` paths changed). See [SPM and CocoaPods workflow](../packaging/spm-and-cocoapods-workflow.md).
3. When a canonical command fails: read the **full** output, fix **product code** (or re-run the documented install step), re-run the **same** command. Do **not** switch invocation style.
4. Do **not** invent alternate destinations, schemes, or simulators from error strings — use the pins in [running tests](running-tests.md) / CI workflows.
5. Subagents (Task, explore, orchestrator): same rule — paste the [handoff block](#subagent-handoff) into every FirebaseUI-iOS task prompt.

## Canonical registry

| Intent | Command | Never use instead |
|--------|---------|-------------------|
| Ruby gems (CocoaPods path) | `bundle install` (repo root) | ad-hoc `gem install cocoapods` as the primary path when `Gemfile` exists |
| UIKit module pods | `cd FirebaseDatabaseUI\|FirebaseFirestoreUI\|FirebaseStorageUI && bundle exec pod install` | `pod install` without Bundler; editing `Podfile.lock` by hand to "fix" CI |
| UIKit module unit tests (one module) | `./test.sh FirebaseDatabaseUI` / `FirebaseFirestoreUI` / `FirebaseStorageUI` (after that module's `pod install`) | bare `xcodebuild` with a different scheme/workspace/destination than `test.sh` |
| UIKit modules local all-three | `./local_test.sh` | inventing a loop of `xcodebuild` flags that diverge from `local_test.sh` |
| SwiftUI Auth CI-local suite | `./swiftui-tests.sh` ([flags](running-tests.md#swiftui-auth-tests)) | hand-rolled `xcodebuild test` that skips `prepare-ios-simulator.sh` / emulator startup |
| SwiftFormat lint | `./lint-swift.sh` or `./swiftui-tests.sh --lint …` | `swiftformat` on arbitrary paths outside the script; inventing SwiftLint |
| SwiftFormat write | `./format-swift.sh` | formatting ObjC UIKit sources with SwiftFormat |
| SPM package list / scheme discover | `xcodebuild -list` (repo root) | assuming scheme names from other repos |
| SPM UIKit product compile check | `xcodebuild -scheme FirebaseDatabaseUI\|FirebaseFirestoreUI\|FirebaseStorageUI -sdk iphonesimulator -destination 'platform=iOS Simulator,OS=latest,name=iPhone 17 Pro'` (matches CI `spm` jobs) | random device names; building macOS/watchOS |
| SPM SwiftUI package unit tests | `./swiftui-tests.sh --unit` (preferred) — wraps `xcodebuild test -scheme FirebaseUI-Package` | `swift test` (this package is iOS-simulator backed) |
| Sample app builds | allowlisted sample `xcodebuild` in [running tests § samples](running-tests.md#sample-builds) | opening Xcode GUI as the agent gate |
| Podspec lint (touched pod) | `bundle exec pod lib lint <Pod>.podspec` (matches CI `pod` jobs) | `pod trunk push` / release scripts during normal PR work |
| Release / staging | **human-only** — [`release.sh`](../../release.sh), [`release-swift.sh`](../../release-swift.sh), [`staging.sh`](../../staging.sh) | agents must not run trunk/push release scripts unless the user explicitly requests |

### Host / toolchain assumptions

- **Xcode:** CI pins **Xcode 26.2** for current workflows (see [CI workflows](../ci-workflows/index.md)). Prefer that version locally when available.
- **Default simulator name:** `iPhone 17 Pro` for module/SwiftUI tests; sample SwiftUI workflow uses `iPhone 17`. Prefer `./swiftui-tests.sh` / `./test.sh` over inventing destinations.
- **Simulator prep:** [`.github/workflows/scripts/prepare-ios-simulator.sh`](../../.github/workflows/scripts/prepare-ios-simulator.sh) is invoked by `swiftui-tests.sh` and CI — do not replace it with ad-hoc `simctl` boot loops unless debugging that script itself.

## Forbidden (always)

| Command / pattern | Why |
|-------------------|-----|
| `swift test` for this package | Targets are iOS; CI uses `xcodebuild test` on simulator |
| `npx` / `yarn` / `npm test` as product validation | Not this repo's test entrypoints (Firebase CLI/`npm` only for Auth emulator via documented scripts) |
| Invented SwiftLint / clang-format agent gates | Swift lint entrypoint is `./lint-swift.sh`; ObjC style is Google Objective-C guide via review, not an agent script today |
| `pod trunk push`, `./release.sh`, `./release-swift.sh` without explicit user request | Publishes artifacts |
| Changing `Package.resolved` / lockfiles to silence dependency errors without product justification | Masks real resolution issues |
| Copying RNFB `yarn tests:*` / Detox / Jet commands | Wrong stack |
| Parallel overlapping simulator test runs on one host | Flaky boots and port contention (Auth emulator `:9099`) |

## Known traps

<a id="known-traps"></a>

### Dual distribution

- Editing `FirebaseDatabaseUI/Sources/**` (etc.) affects **both** CocoaPods workspaces and SPM targets in `Package.swift`. Validate the path(s) you changed — see [SPM and CocoaPods workflow](../packaging/spm-and-cocoapods-workflow.md).
- SwiftUI Auth lives under `FirebaseSwiftUI/**` and is **SPM-first**; do not invent CocoaPods subspecs for those products.

### Auth emulator

- Integration/UI tests need Firebase CLI + Node; canonical start is inside `./swiftui-tests.sh` or `e2eTest/.../start-firebase-emulator.sh`.
- Defaults (project id, port): [firebase testing project](firebase-testing-project.md). Do not invent alternate emulator suites.

### Workspace vs project

- UIKit module tests use **`.xcworkspace`** after `pod install` (`./test.sh`).
- SwiftUI sample / e2e example use **`.xcodeproj`** under `samples/swiftui/` and `e2eTest/`.
- Package unit tests use scheme **`FirebaseUI-Package`** at repo root.

## Subagent handoff

Paste into Task / explore / work-queue prompts:

```text
FirebaseUI-iOS agent command policy: okf-bundle/testing/agent-command-policy.md ONLY.
SwiftUI Auth tests: ./swiftui-tests.sh [--unit|--integration|--ui|--lint|--all] ONLY.
UIKit module tests: bundle exec pod install in module dir, then ./test.sh FirebaseDatabaseUI|FirebaseFirestoreUI|FirebaseStorageUI.
Lint Swift: ./lint-swift.sh (or ./swiftui-tests.sh --lint …). Format: ./format-swift.sh.
Never: swift test, yarn/detox/jet, invented xcodebuild destinations, pod trunk / release-*.sh without explicit user request.
On failure: fix product code, re-run the same canonical command.
Gate close / push: return validation evidence per okf-bundle/testing/change-authoring-workflow.md#validation-evidence-blocking.
```

## Related docs

| Topic | Owner |
|-------|--------|
| Test commands, emulator, narrowing | [running-tests.md](running-tests.md) |
| Handoff validation sequence | [validation-checklist.md](validation-checklist.md) |
| Work types and gates | [change-authoring-workflow.md](change-authoring-workflow.md) |
| Doc / commit policy | [documentation-policy.md](../documentation-policy.md) |
| SPM vs CocoaPods | [spm-and-cocoapods-workflow.md](../packaging/spm-and-cocoapods-workflow.md) |
| Auth emulator project / ports | [firebase-testing-project.md](firebase-testing-project.md) |
