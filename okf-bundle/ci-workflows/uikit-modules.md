---
type: Reference
title: UIKit modules CI
description: Job shape for Database, Firestore, and Storage UI GitHub Actions workflows.
tags: [ci, database, firestore, storage, cocoapods, spm]
timestamp: 2026-07-31T00:00:00Z
---

# UIKit modules CI

Workflows (same job shape):

* [`.github/workflows/database.yml`](../../.github/workflows/database.yml)
* [`.github/workflows/firestore.yml`](../../.github/workflows/firestore.yml)
* [`.github/workflows/storage.yml`](../../.github/workflows/storage.yml)

Local mirror for the CocoaPods test job: [`./test.sh <Module>`](../../test.sh) after `bundle exec pod install` in the module directory — [running tests](../testing/running-tests.md#uikit-module-tests-cocoapods).

## Jobs (per module)

| Job | What |
|-----|------|
| `xcodebuild` | In module dir: Bundler + `pod install --repo-update`, then repo-root `./test.sh <Module>` |
| `spm` | Repo-root `xcodebuild -scheme <Module> -sdk iphonesimulator` with CI destination |
| `pod` | `bundle exec pod lib lint <Module>.podspec` |

## Environment

| Pin | Value |
|-----|-------|
| Runner | `macos-15` |
| Xcode | `/Applications/Xcode_26.2.app` via `xcode-select` |
| Destination (spm / test.sh) | `iPhone 17 Pro` (see scripts/workflows for exact string) |

## Path filters

Each workflow watches its `Firebase<Module>UI/**`, podspec, `test.sh`, `Package.swift` / `Package.resolved`, Gemfile, and its workflow file.

## Dual-path reminder

A green `xcodebuild` CocoaPods job does **not** prove the SPM product compiles (and vice versa). Agents must satisfy the [distribution path gate](../testing/running-tests.md#distribution-path-gate-blocking) when shared sources change.
