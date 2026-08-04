---
type: Reference
title: Firebase testing project
description: Auth emulator project id, ports, and local vs CI usage for FirebaseUI-iOS SwiftUI tests.
tags: [testing, emulator, firebase, auth]
timestamp: 2026-07-31T00:00:00Z
---

# Firebase testing project

Canonical notes for the Firebase project / emulator used by SwiftUI Auth integration and UI tests. Command ownership stays in [agent command policy](agent-command-policy.md) and [running tests](running-tests.md).

## Defaults

| Setting | Value |
|---------|-------|
| Firebase project id | `flutterfire-e2e-tests` |
| Override | `FIREBASE_PROJECT=<id>` when invoking `./swiftui-tests.sh` |
| Emulator | Auth only (`firebase emulators:start --only auth`) |
| Readiness probe | `http://localhost:9099` |
| Host app config | `e2eTest/FirebaseSwiftUIExample/FirebaseSwiftUIExample/` (`firebase.json`, `start-firebase-emulator.sh`) |

## Local vs CI

| Context | How emulator starts |
|---------|---------------------|
| Local | Prefer `./swiftui-tests.sh --integration` / `--ui` (starts or reuses emulator) |
| CI | [`.github/workflows/swiftui-auth.yml`](../../.github/workflows/swiftui-auth.yml) runs `start-firebase-emulator.sh` in the example app directory |

Do not invent alternate emulator suites or project ids for agent gates. UIKit Database/Firestore/Storage module XCTest suites do **not** use this Auth emulator path.
