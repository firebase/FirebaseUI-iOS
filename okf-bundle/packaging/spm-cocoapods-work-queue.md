---
type: Reference
title: SPM / CocoaPods distribution work queue
description: Phase tracker for dual-distribution gaps and packaging follow-ups.
tags: [spm, cocoapods, work-queue, ephemeral]
timestamp: 2026-07-31T00:00:00Z
---

# SPM / CocoaPods work queue

Ephemeral. Field ids: [iteration vocabulary](../testing/iteration-vocabulary.md). Durable rules: [SPM and CocoaPods workflow](spm-and-cocoapods-workflow.md). Commit/doc policy: [documentation policy](../documentation-policy.md).

Do not copy policy into this file — link only.

## Active items

| id | item | next_work_type | validation_tier | implementation_gate | review_gate | commit_gate | commit_subject | notes |
|----|------|----------------|-----------------|----------------------|-------------|-------------|----------------|-------|
| DIST-1 | Keep OKF dual-distribution docs aligned when CI Xcode/simulator pins or podspec/SPM matrix change | `documentation` | none | open | open | open | | Standing maintenance item; reopen whenever CI pins or product matrix drift |
| DIST-2 | Clarify / close any remaining consumer messaging gaps between README SPM-vs-CocoaPods guidance and Package.swift product list | `gap-analysis` | none | open | open | open | | Durable outcome → [spm-and-cocoapods-workflow.md](spm-and-cocoapods-workflow.md) Decision log |

## Parked / blocked

| id | item | blocked | notes |
|----|------|---------|-------|
| — | — | — | — |

## Archive

_None yet._
