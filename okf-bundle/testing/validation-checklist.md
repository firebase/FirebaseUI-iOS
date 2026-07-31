---
type: Reference
title: Validation checklist
description: Canonical command sequence for validating FirebaseUI-iOS changes and handoff.
tags: [testing, validation, lint, xcodebuild, cocoapods]
timestamp: 2026-07-31T00:00:00Z
---

# Validation checklist

Validation commands for development/handoff. Other docs link here; do not restate.

Coverage expectations: [coverage design](coverage-design.md).

## When to run what

Work types and tiers: [change authoring workflow](change-authoring-workflow.md). Term ids: [iteration vocabulary](iteration-vocabulary.md).

| Work type | Scope | Shortcuts |
|-----------|-------|-----------|
| `gap-analysis` | Read APIs, `Package.swift`, podspecs, provider docs | n/a |
| `baseline-capture` | Area suite for the module | **area-focused**; no permanent skips |
| `implementation` | Unit-focused suite for touched area + lint when Swift touched | **unit-focused**; see [running tests](running-tests.md) |
| `independent-review` | Area-focused full area suite + applicable rows below | **area-focused**; [frozen tree](change-authoring-workflow.md#frozen-tree) |
| `pre-merge-validation` | All CI-equivalent suites affected by the branch | **full** tier |

## Lint and formatting

<a id="lint-and-formatting"></a>

When `FirebaseSwiftUI/**`, `samples/swiftui/**`, `e2eTest/**`, or `Package.swift` change:

```bash
./lint-swift.sh
# or
./swiftui-tests.sh --lint --unit
```

To apply formatting:

```bash
./format-swift.sh
```

ObjC UIKit modules: follow [Google Objective-C style](https://google.github.io/styleguide/objcguide.xml) in review; there is no agent SwiftFormat gate for those trees today.

## SwiftUI Auth / SPM package

```bash
./swiftui-tests.sh --unit                         # package unit tests
./swiftui-tests.sh --integration                  # emulator + integration
./swiftui-tests.sh --ui                           # emulator + UI tests
./swiftui-tests.sh --lint --all                   # area-focused / pre-merge for Auth
```

## UIKit modules (CocoaPods)

From repo root, after `bundle install` once:

```bash
cd FirebaseDatabaseUI && bundle exec pod install && cd ..
./test.sh FirebaseDatabaseUI
# repeat for FirebaseFirestoreUI / FirebaseStorageUI when those trees change
```

## SPM compile check (shared UIKit sources)

When `Package.swift` or shared UIKit sources change:

```bash
xcodebuild -scheme FirebaseDatabaseUI -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,OS=latest,name=iPhone 17 Pro'
# FirebaseFirestoreUI / FirebaseStorageUI as needed
```

## Podspec lint

When a podspec or its packaged sources change:

```bash
bundle install
bundle exec pod lib lint FirebaseDatabaseUI.podspec
# FirebaseFirestoreUI.podspec / FirebaseStorageUI.podspec / FirebaseUI.podspec as needed
```

Do **not** run `pod trunk push` / `./release.sh` as part of ordinary validation.

## Samples

When `samples/**` or packaging that samples consume changes, run the matching jobs from [running tests § samples](running-tests.md#sample-builds) / [sample CI](../ci-workflows/samples.md).

## OKF bundle review

Before handoff, follow [OKF policy](../documentation-policy.md#okf-update-contract):

1. Update relevant `okf-bundle/packages/<pkg>/` docs with durable learnings.
2. Check `okf-bundle/testing/` and `okf-bundle/packaging/` for conflicts with verified behavior; fix drift.
3. Run independent scan for canonical ownership, DRY refs, link hygiene, durability.

<a id="validation-evidence-package"></a>

## Validation evidence package (blocking)

Before closing **`implementation_gate`**, **`review_gate`**, **`commit_gate`**, or publishing (`git push` / PR update), record evidence per [change authoring § validation evidence](change-authoring-workflow.md#validation-evidence-blocking). Minimum template:

```markdown
| Step | Command | Exit | Evidence |
|------|---------|------|----------|
| lint (Swift) | ./lint-swift.sh | 0 | when SwiftFormat paths touched |
| swiftui unit | ./swiftui-tests.sh --unit | 0 | when FirebaseSwiftUI / Package SwiftUI products touched |
| swiftui integration | ./swiftui-tests.sh --integration | 0 | when auth flows / e2eTest touched |
| swiftui UI | ./swiftui-tests.sh --ui | 0 | when UI / UITest surface touched |
| uikit module | ./test.sh FirebaseDatabaseUI | 0 | when that module touched |
| spm scheme | xcodebuild -scheme FirebaseDatabaseUI … | 0 | when Package.swift / shared sources touched |
| pod lib lint | bundle exec pod lib lint … | 0 | when podspec touched |
| sample build | (CI-equivalent xcodebuild) | 0 | when samples touched |
```

**History rewrite invalidates** prior rows — re-run and replace the table after amend/rebase.

## Handoff checklist

- [ ] [Distribution path gate](running-tests.md#distribution-path-gate-blocking) satisfied for UIKit shared sources
- [ ] `./lint-swift.sh` when SwiftFormat-covered paths changed
- [ ] SwiftUI: appropriate `./swiftui-tests.sh` flags green
- [ ] UIKit: `./test.sh <Module>` green for each touched module
- [ ] SPM scheme build when `Package.swift` / shared UIKit sources changed
- [ ] `pod lib lint` when podspecs changed
- [ ] Sample builds when samples changed
- [ ] [Validation evidence package](#validation-evidence-package) recorded
- [ ] OKF bundle reviewed/updated per § above
- [ ] Feature parity considered for user-facing Auth/UI ([`CONTRIBUTING.md`](../../CONTRIBUTING.md))
