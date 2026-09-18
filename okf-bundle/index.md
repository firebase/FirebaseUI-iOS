---
okf_version: '0.1'
---

# FirebaseUI-iOS knowledge bundle

Agent-oriented knowledge for this repository. Prefer these docs over improvised shell diagnostics or copying patterns from other FirebaseUI / React Native Firebase repos without re-deriving commands from this tree.

- [Documentation/commit policy](/documentation-policy.md) — durable vs ephemeral, commits as documentation, PR titles, OKF consistency

# Testing

- [Agent command policy](/testing/agent-command-policy.md) — allowlisted shell commands (install, lint, unit, integration, UI, CocoaPods)
- [Change authoring workflow](/testing/change-authoring-workflow.md) — verified change loop (unit-focused → area-focused review → commit); [§ validation evidence (blocking)](testing/change-authoring-workflow.md#validation-evidence-blocking)
- [Iteration vocabulary](/testing/iteration-vocabulary.md) — work type, tier, and queue field identifiers
- [Running tests](/testing/running-tests.md) — canonical SwiftUI and UIKit test commands, narrowing, emulator
- [Validation checklist](/testing/validation-checklist.md) — lint, SPM package tests, CocoaPods module tests, samples, pod lint
- [Coverage design](/testing/coverage-design.md) — where coverage is produced and how to treat it
- [Firebase testing project](/testing/firebase-testing-project.md) — Auth emulator project id, ports, local vs CI

# CI workflows

- [CI workflows](/ci-workflows/index.md) — GitHub Actions job map, Xcode/simulator pins, artifact triage

# Packaging

- [SPM and CocoaPods workflow](/packaging/spm-and-cocoapods-workflow.md) — dual distribution rules, product matrix, release scripts
- [SPM / CocoaPods work queue](/packaging/spm-cocoapods-work-queue.md) — ephemeral dual-distribution tracker

# Packages

- [Packages index](/packages/index.md) — Auth SwiftUI, Database UI, Firestore UI, Storage UI
