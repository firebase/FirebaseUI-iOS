---
type: Reference
title: Running tests
description: Canonical SwiftUI Auth and UIKit module test commands, emulator, narrowing, and distribution-path gate.
tags: [testing, xcodebuild, emulator, swiftui, cocoapods]
timestamp: 2026-07-31T00:00:00Z
---

# Running tests

Canonical **how to invoke** tests in this repo. Allowlist ownership: [agent command policy](agent-command-policy.md). Do not restate the allowlist here.

<a id="agent-rule-read-first"></a>

## Agent rule (read first)

1. Prefer wrapper scripts (`./swiftui-tests.sh`, `./test.sh`, `./local_test.sh`, `./lint-swift.sh`) over hand-built `xcodebuild` lines.
2. When you must call `xcodebuild` directly, match **scheme / workspace-or-project / destination** to CI or to the wrappers above.
3. On failure: fix product code (or documented setup), re-run the **same** command.

## Validation tiers

<a id="validation-tiers"></a>

| Tier | SwiftUI Auth (`FirebaseSwiftUI/**`, `Package.swift` SwiftUI products) | UIKit modules (`FirebaseDatabaseUI`, `FirebaseFirestoreUI`, `FirebaseStorageUI`) |
|------|------------------------------------------------------------------------|----------------------------------------------------------------------------------|
| `unit-focused` | `./swiftui-tests.sh --unit` (optional `--lint`) | `bundle exec pod install` in module dir → `./test.sh <Module>` |
| `area-focused` | `./swiftui-tests.sh --lint --all` | `./test.sh <Module>` **and** SPM scheme build for that product if `Package.swift` shares sources |
| `full` | area-focused + sample SwiftUI build + any touched CI path | all three modules as needed + sample UIKit builds + `pod lib lint` for touched podspecs |

Work-type mapping: [change authoring](change-authoring-workflow.md).

<a id="distribution-path-gate-blocking"></a>

## Distribution path gate (blocking)

Sources under `FirebaseDatabaseUI/Sources`, `FirebaseFirestoreUI/Sources`, and `FirebaseStorageUI/Sources` are consumed by **CocoaPods workspaces and SPM targets**. Closing `implementation` / `review` for those trees requires the CocoaPods test path **and**, when `Package.swift` or shared headers changed, the CI-equivalent SPM scheme build.

SwiftUI Auth sources under `FirebaseSwiftUI/**` are **SPM-only** for product delivery — use `./swiftui-tests.sh`, not CocoaPods.

Details: [SPM and CocoaPods workflow](../packaging/spm-and-cocoapods-workflow.md). Emulator project: [firebase testing project](firebase-testing-project.md).

## SwiftUI Auth tests

<a id="swiftui-auth-tests"></a>

Local equivalent of [`.github/workflows/swiftui-auth.yml`](../../.github/workflows/swiftui-auth.yml):

```bash
./swiftui-tests.sh                  # unit + integration + UI (default)
./swiftui-tests.sh --unit
./swiftui-tests.sh --integration --ui
./swiftui-tests.sh --lint --all
./swiftui-tests.sh --device "iPhone 17 Pro" --ui
FIREBASE_PROJECT="my-firebase-project" ./swiftui-tests.sh --integration
```

| Flag | What runs |
|------|-----------|
| `--unit` | `xcodebuild test -scheme FirebaseUI-Package` (package unit tests) |
| `--integration` | `FirebaseSwiftUIExampleTests` with Auth emulator |
| `--ui` | `FirebaseSwiftUIExampleUITests` build-for-testing + test-without-building |
| `--lint` | `./lint-swift.sh` before selected tests |
| `--device NAME` | Simulator device name (default `iPhone 17 Pro`) |

**Requirements for `--integration` / `--ui`:** Firebase CLI, Node.js, npm. Emulator listens on `http://localhost:9099`. Default project: `flutterfire-e2e-tests`.

**Logs / result bundles** (written by the script / CI):

| Suite | Log (typical) | `.xcresult` |
|-------|---------------|-------------|
| Package unit | `FirebaseSwiftUIPackageTests.log` | `FirebaseSwiftUIPackageTests.xcresult` |
| Integration | `e2eTest/FirebaseSwiftUIExample/FirebaseSwiftUIExampleTests.log` | `…/FirebaseSwiftUIExampleTests.xcresult` |
| UI | `e2eTest/FirebaseSwiftUIExample/FirebaseSwiftUIExampleUITests.log` | `…/FirebaseSwiftUIExampleUITests.xcresult` |

Project id / port defaults: [firebase testing project](firebase-testing-project.md).

### Narrowing (local only)

- Prefer `--unit` during `unit-focused` implementation when only package logic changed.
- Prefer `--integration` or `--ui` alone when diagnosing that layer.
- **Never commit** permanent skips that disable CI-equivalent coverage without an [acceptable exception](change-authoring-workflow.md#acceptable-exceptions).
- Xcode test focusing (`testFoo` only via IDE) is fine locally; agent gates should still re-run the scripted suite for the tier.

## UIKit module tests (CocoaPods)

<a id="uikit-module-tests"></a>

```bash
cd FirebaseDatabaseUI   # or FirebaseFirestoreUI / FirebaseStorageUI
bundle exec pod install
cd ..
./test.sh FirebaseDatabaseUI
```

`./test.sh` runs `xcodebuild` against `$module.xcworkspace` / scheme `$module`, iPhone simulator destination pinned in the script (`iPhone 17 Pro` as of authoring).

All three locally (also updates pod repos):

```bash
./local_test.sh
```

**Note:** `local_test.sh` pins **`iPhone 16 Pro`**, while `./test.sh` and CI module/`spm` jobs pin **`iPhone 17 Pro`**. Prefer `./test.sh` for agent gates so the destination matches CI.

## SPM scheme builds (UIKit products)

CI `spm` jobs compile SPM products without the CocoaPods workspace:

```bash
xcodebuild -scheme FirebaseDatabaseUI -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,OS=latest,name=iPhone 17 Pro'
```

Same pattern for `FirebaseFirestoreUI` and `FirebaseStorageUI`.

## Sample builds

<a id="sample-builds"></a>

Match [`.github/workflows/sample.yml`](../../.github/workflows/sample.yml) when samples or shared packaging change:

```bash
# SwiftUI sample
cd samples/swiftui/FirebaseSwiftUISample
xcodebuild -project FirebaseSwiftUISample.xcodeproj -scheme FirebaseSwiftUISample \
  -sdk iphonesimulator -destination 'platform=iOS Simulator,OS=latest,name=iPhone 17' \
  clean build ONLY_ACTIVE_ARCH=YES
```

UIKit samples under `samples/swift` / `samples/objc` follow the same workflow file (CocoaPods install then `xcodebuild`; the Swift demo runs **`clean build test`**, ObjC runs **`clean build`**) — copy flags from CI rather than inventing them. See [samples CI](../ci-workflows/samples.md).

## Lint / format

```bash
./lint-swift.sh      # CI format-check job
./format-swift.sh    # rewrite SwiftFormat paths
```

Paths covered: `FirebaseSwiftUI/`, `samples/swiftui/FirebaseSwiftUISample/`, `e2eTest/`, `Package.swift`.

## Related docs

| Topic | Document |
|-------|----------|
| Allowlist / bans | [agent-command-policy.md](agent-command-policy.md) |
| Handoff sequence | [validation-checklist.md](validation-checklist.md) |
| CI job map | [../ci-workflows/index.md](../ci-workflows/index.md) |
| Coverage | [coverage-design.md](coverage-design.md) |
