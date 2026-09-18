---
type: Reference
title: Coverage design
description: How FirebaseUI-iOS produces coverage and how agents should treat coverage evidence.
tags: [testing, coverage, xcodebuild]
timestamp: 2026-07-31T00:00:00Z
---

# Coverage design

This repo enables Xcode code coverage on SwiftUI Auth CI jobs (`-enableCodeCoverage YES` with `.xcresult` bundles). It does **not** currently publish a Codecov-style merge gate comparable to React Native Firebase. Treat coverage as a **signal for review**, not a numeric CI pass/fail owned by OKF.

## Where coverage is produced

| Suite | How | Artifact |
|-------|-----|----------|
| SPM package unit (`FirebaseUI-Package`) | `./swiftui-tests.sh --unit` / CI `unit-tests` job | `FirebaseSwiftUIPackageTests.xcresult` |
| Integration | `./swiftui-tests.sh --integration` | `e2eTest/.../FirebaseSwiftUIExampleTests.xcresult` |
| UI | `./swiftui-tests.sh --ui` | `e2eTest/.../FirebaseSwiftUIExampleUITests.xcresult` |
| UIKit CocoaPods module tests | `./test.sh <Module>` (CI module workflows) | Xcode test result under the module workspace run |

Inspect `.xcresult` in Xcode or with `xcrun xccov` when investigating gaps. Do not invent a parallel coverage toolchain.

## Expectations (policy)

<a id="coverage-expectations-policy"></a>

1. New or changed behavior should ship with tests at the appropriate layer (package unit vs integration vs UI vs UIKit XCTest).
2. Before closing **`review`** on non-trivial product diffs, skim coverage / failing regions for the touched files when an `.xcresult` exists — investigate reachable untsted lines ([change authoring § quality standards](change-authoring-workflow.md#quality-standards)).
3. Do not claim "100% coverage required" as a repo-wide gate unless CI grows an explicit threshold; do not skip writing tests because no Codecov gate exists.

<a id="coverage-evidence-package"></a>

## Coverage evidence package

When closing `review` on SwiftUI Auth or UIKit module product code, attach a short note:

```markdown
| Surface | Suite | Result | Notes |
|---------|-------|--------|-------|
| <files/modules> | unit / integration / UI / uikit | pass + .xcresult path | gaps investigated: … |
```

If coverage was not collected (tooling failure), say so explicitly — do not imply it ran.
