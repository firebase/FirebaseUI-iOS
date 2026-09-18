---
type: Reference
title: Iteration vocabulary
description: Identifier glossary and work-queue field schema for OKF — not workflow rules or commands.
tags: [testing, validation, workflow, work-queue]
timestamp: 2026-07-31T00:00:00Z
---

# Iteration vocabulary

Glossary of **string identifiers** and **work-queue field names** used across OKF. This doc does not define procedures, gate rules, or test commands — each topic has one owning doc; others link.

**Policy:** [OKF documentation and commit policy](../documentation-policy.md).

| Topic | Owner |
|-------|--------|
| Change loop, gates, frozen tree, host rule | [change authoring workflow](change-authoring-workflow.md) |
| **All agent shell commands** | [agent command policy](agent-command-policy.md) |
| Test command detail, emulator, narrowing | [running tests](running-tests.md) |
| Validation command sequence | [validation checklist](validation-checklist.md) |
| Work-queue gate snapshots | Package/module work queues (ephemeral) |

## Work type identifiers

| Work type | Brief meaning |
|-----------|---------------|
| `gap-analysis` | Read-only feasibility / semantics check |
| `baseline-capture` | Record before snapshots or baselines |
| `implementation` | Author product code and tests |
| `independent-review` | Verify a frozen diff |
| `documentation` | User docs and durable OKF updates |
| `commit` | Stage and create one commit |
| `pre-merge-validation` | Branch-wide merge gate |

When to use each work type, validation tier, edit policy, and commit rules: [change authoring § work types](change-authoring-workflow.md#work-types).

## Validation tier identifiers

| Tier id | Brief meaning |
|---------|---------------|
| `unit-focused` | Fast validation while product code is changing |
| `area-focused` | Full loaded module/area suite for the change |
| `full` | Unfocused — all relevant modules and CI-equivalent suites |

Test scope per tier: [change authoring § validation tiers](change-authoring-workflow.md#validation-tiers), [running tests § validation tiers](running-tests.md#validation-tiers).

## Gate identifiers

Work queues use these **field names** (values: `open` | `closed`):

| Field | Tracks |
|-------|--------|
| `implementation_gate` | `implementation` work type complete |
| `review_gate` | `independent-review` work type complete |
| `commit_gate` | Durable commit exists for the item **after** prior gates closed with [validation evidence](change-authoring-workflow.md#validation-evidence-blocking) |

What closes each gate: [change authoring § gates](change-authoring-workflow.md#gates).

`commit_gate` closes when a durable commit exists whose subject matches the row's `commit_subject`, **after** `implementation_gate` and `review_gate` closed with validation evidence.

Items may also be marked **`blocked`** when a dependency gate is open elsewhere.

## Work-queue fields

Ephemeral work queues may record:

| Field | Allowed values / meaning |
|-------|--------------------------|
| `next_work_type` | A [work type identifier](#work-type-identifiers) |
| `validation_tier` | `unit-focused` \| `area-focused` \| `full` |
| `platform` | Optional scope (this repo is iOS-only; use module ids e.g. `swiftui-auth`, `database-ui`) |
| `implementation_gate` | `open` \| `closed` |
| `review_gate` | `open` \| `closed` |
| `commit_gate` | `open` \| `closed` |
| `commit_subject` | Planned or landed **first line** of the item's focused commit (Conventional Commits subject). Set **before** `git commit`; must match the commit that closes `commit_gate`. Do not record SHAs. |
| `blocked` | Item or dependency blocked until named gate closes |

Queues record **state**, not who executes the work.

## Related docs

| Topic | Document |
|-------|----------|
| **Change authoring loop** | [change-authoring-workflow.md](change-authoring-workflow.md) |
| Test commands | [running-tests.md](running-tests.md) |
| Validation commands | [validation-checklist.md](validation-checklist.md) |
| Doc/commit policy | [documentation-policy.md](../documentation-policy.md) |
