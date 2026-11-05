---
type: Reference
title: FirebaseAuthSwiftUI package notes
description: Agent reference for SwiftUI Auth core and provider packages.
tags: [auth, swiftui, spm]
timestamp: 2026-11-03T00:00:00Z
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

## Customization

Three tiers, all additive: theming, layout, and per-screen content. `AuthService` keeps owning navigation, MFA resolution, account conflicts, reauthentication, loading state and error reporting in every tier.

| Tier | Public surface |
|------|----------------|
| Theming | `.authCTAButtonStyle(_:)`, `.authTextFieldStyle(_:)` and `.authTypography(_:)` set `AuthCTAButtonStyle`, `AuthTextFieldStyle` and `AuthTypography` in the environment; `.authFont(_:weight:)` applies the typography to consumer text. Stock markup uses the internal `.authCTAButtonStyle()` and package `.authCustomFont(_:weight:)` |
| Layout | `AuthPickerView.pickerContent { }` / `pickerContent { state in }` and `.pickerDestination { screen in }`, returning `AuthPickerContent`, with stock `DefaultAuthPickerContent` and `DefaultAuthPickerDestination`; `DefaultAuthPickerContent(authMethodPicker:)` with `AuthMethodPickerState` lays out the provider buttons, with stock `DefaultAuthMethodPicker` |
| Per-screen content | `EnterPhoneNumberScreen` + `PhoneNumberContentState` + `DefaultEnterPhoneNumberContent`; `EnterVerificationCodeScreen` + `VerificationCodeContentState` + `DefaultEnterVerificationCodeContent`; `MFAEnrolmentScreen` + `MFAEnrolmentContentState` + `DefaultMFAEnrolmentContent`; `EmailAuthScreen` + `EmailAuthContentState` + `DefaultEmailAuthContent` (also `SignInView` / `SignUpView` for `AuthView.signIn` / `.signUp`); `PasswordRecoveryScreen` + `PasswordRecoveryContentState` + `DefaultPasswordRecoveryContent`; `EmailLinkScreen` + `EmailLinkContentState` + `DefaultEmailLinkContent` |

Consumers reach a per-screen slot through `.pickerDestination`, matching the `AuthView` case and returning the screen with their content, or `DefaultAuthPickerDestination(screen:)` for every other case.

### Per-screen content slot rules

* **Do not make the existing view generic.** Each screen keeps its public, non-generic `XView` with its existing initializer; its body becomes `XScreen { DefaultXContent(state: $0) }`. Making `XView` generic breaks consumer code such as `let v: MFAEnrolmentView`.
* **`XScreen<Content>` owns the logic.** It holds the `@State`, runs the actions, applies modifiers that must survive custom content (`.withReauthentication(coordinator:)`, `.onChange` error clearing, timers), and takes `@ViewBuilder content: @escaping (XContentState) -> Content`. `ReauthenticationCoordinator` stays private to the screen.
* **`DefaultXContent(state:)` is public** and holds the stock markup unchanged, including accessibility identifiers (UI tests depend on them) and theming modifiers. Consumers wrap it to keep the stock UI. Naming is `Default` + slot name.
* **Fonts in stock markup:** text that had an explicit font before theming uses `.authFont(_:weight:)`; text that had none uses the package-only `.authCustomFont(_:weight:)`, which applies only when `AuthTypography.fontName` is set, so an app-level `.font(...)` still reaches it.
* **`XContentState`** exposes `Binding`s for input, `@MainActor` closures for actions, and `let`s for display, plus `isValid`, `isLoading` and `errorMessage: String?`. `errorMessage` is the localized message from `authService.string.localizedErrorMessage(for:)`. Screens set it instead of calling `reportError`, so the sheet's alert doesn't show it; the stock `DefaultXContent` shows it in the same alert, and the state's `dismissError` clears it. Errors the sheet's alert skips (`shouldShowErrorAlert(for:)`) leave it `nil`. The phone and MFA enrolment screens still call `reportError` until the follow-up PR aligns them. No typed error.
* **Guards live in the screen**, not the content: every action closure checks `isValid` / `isLoading` / step itself, so custom content cannot trigger it in the wrong state. Keep guard and step rules in pure internal helpers so `./swiftui-tests.sh --unit` covers them.
* **Navigation titles live in the default content**, so custom content sets its own.
* **Every parameter of the state's public initializer has a default**, so consumer previews pass only what they need. New fields always get a default, so adding one never breaks a caller; `ContentStateDefaultsTests` builds each state with no arguments to enforce this.
* **Public step enums** (`MFAEnrolmentContentState.Step`) document that cases may be added, so consumers keep a `default` case.
* **Spelling:** view-layer types use "Enrolment" (`MFAEnrolmentView`, `MFAEnrolmentScreen`, `MFAEnrolmentContentState`); service-layer API keeps "Enrollment" (`EnrollmentSession`, `startMfaEnrollment`, `AuthView.mfaEnrollment`).

Not slotted: `LegacySignInRecoveryView` (its own sheet, outside `pickerDestination`) and the reauthentication views.

## Related

* [SPM and CocoaPods workflow](../../packaging/spm-and-cocoapods-workflow.md) — Auth is SPM-only for consumers
* [`.agents/skills/firebaseui-ios-getting-started/SKILL.md`](../../../.agents/skills/firebaseui-ios-getting-started/SKILL.md) — getting-started skill (user docs adjacent)
