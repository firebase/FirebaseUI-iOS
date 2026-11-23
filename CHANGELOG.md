# Changelog

All notable changes to FirebaseUI for iOS are recorded here. Earlier releases are described in the [GitHub releases](https://github.com/firebase/FirebaseUI-iOS/releases).

## Unreleased

Changes since [v16.2.0](https://github.com/firebase/FirebaseUI-iOS/releases/tag/v16.2.0). Most of this release makes the SwiftUI auth flow (`FirebaseAuthSwiftUI`) customizable: themes, whole-screen content slots and per-screen state, as proposed in [#1400](https://github.com/firebase/FirebaseUI-iOS/issues/1400).

### ⚠️ Breaking Changes

- `AuthView` gains `signIn` and `signUp` cases, so an exhaustive `switch` over `AuthView` needs new branches or a `default:` ([#1414](https://github.com/firebase/FirebaseUI-iOS/pull/1414)).
- `AuthServiceError` gains `multiFactorReauthenticationRequired(MFARequired)`, so an exhaustive `switch` over `AuthServiceError` needs a new case. `reauthenticate(with:)` and `reauthenticate(context:)` throw it instead of Firebase's raw `secondFactorRequired` error ([#1419](https://github.com/firebase/FirebaseUI-iOS/pull/1419)).

### Behaviour changes

- Default appearance: `MFAResolutionView` buttons now use the same styles as the other MFA screens, and in `EmailAuthView` the sign up label goes from semibold to medium and the password recovery label is now medium ([#1402](https://github.com/firebase/FirebaseUI-iOS/pull/1402)).
- Closing the auth sheet clears its navigation, so reopening it starts on the first screen instead of a pushed screen such as MFA or update password ([#1414](https://github.com/firebase/FirebaseUI-iOS/pull/1414)).
- Swiping away a reauthentication sheet now cancels reauthentication instead of leaving the waiting operation hanging ([#1417](https://github.com/firebase/FirebaseUI-iOS/pull/1417), [#1419](https://github.com/firebase/FirebaseUI-iOS/pull/1419)).
- Phone and anonymous users no longer see the Verify email action on the signed-in screen ([#1417](https://github.com/firebase/FirebaseUI-iOS/pull/1417)).
- `DefaultAuthPickerContent`'s provider list selects a provider that is neither credential-based nor an `AuthProviderAction` by reporting an error instead of doing nothing ([#1411](https://github.com/firebase/FirebaseUI-iOS/pull/1411)).
- MFA enrolment keeps Get Started disabled until the selected factor is allowed (it used to start SMS enrolment regardless), and expired or finished sessions return to factor selection ([#1415](https://github.com/firebase/FirebaseUI-iOS/pull/1415)).

### 🚀 New Features

#### Theming

- `AuthTextFieldStyle`, `AuthCTAButtonStyle` and `AuthTypography`, set with `.authTextFieldStyle(_:)`, `.authCTAButtonStyle(_:)` and `.authTypography(_:)` and carried through the environment to every screen in the auth sheet. Unset values keep the default look and leave an app's own `.font`, `.tint` and `.buttonBorderShape` in place ([#1402](https://github.com/firebase/FirebaseUI-iOS/pull/1402)).
- `FirebaseAuthSwiftUI` re-exports `FirebaseAuthUIComponents`, so the theming types are available from `import FirebaseAuthSwiftUI` ([#1402](https://github.com/firebase/FirebaseUI-iOS/pull/1402)).

#### Replacing screens

- `AuthPickerView` gains `.pickerContent { }` and `.pickerContent { state in }` to replace the first screen, and `.pickerDestination { screen in }` to replace pushed screens, while the library keeps driving navigation, MFA and account conflicts. `DefaultAuthPickerContent`, `DefaultAuthMethodPicker` and `DefaultAuthPickerDestination` hold the stock screens ([#1403](https://github.com/firebase/FirebaseUI-iOS/pull/1403), [#1411](https://github.com/firebase/FirebaseUI-iOS/pull/1411)).
- `DefaultAuthPickerContent(authMethodPicker:)` lays out the provider buttons with an `AuthMethodPickerState`. `AuthService` gains `registeredProviders` and `triggerSignIn(for:)`, and providers without a credential can adopt `AuthProviderAction` ([#1411](https://github.com/firebase/FirebaseUI-iOS/pull/1411)).
- `.signedInContent { state in }` replaces the screen shown to signed-in users, with `DefaultSignedInContent` as the default ([#1417](https://github.com/firebase/FirebaseUI-iOS/pull/1417)).
- `.reauthContent { prompt in }` replaces the password, phone and email-link reauthentication prompts ([#1423](https://github.com/firebase/FirebaseUI-iOS/pull/1423)).

#### Per-screen content slots

Each screen below owns its logic and passes its content a state value with bindings for input, actions, `isValid`, `isLoading` and a localized `errorMessage`. A matching `Default…Content` holds the stock markup, and the existing views keep their signatures.

- Phone: `EnterPhoneNumberScreen` and `EnterVerificationCodeScreen`. The verification screen adds Resend Code with a 60 second countdown ([#1412](https://github.com/firebase/FirebaseUI-iOS/pull/1412)).
- Email: `EmailAuthScreen`, `PasswordRecoveryScreen` and `EmailLinkScreen`. New `AuthView.signIn` and `AuthView.signUp` routes, shown as `SignInView` and `SignUpView`, give a custom first screen separate sign-in and sign-up screens ([#1414](https://github.com/firebase/FirebaseUI-iOS/pull/1414)).
- MFA: `MFAEnrolmentScreen`, `MFAResolutionScreen` and `MFAManagementScreen` ([#1415](https://github.com/firebase/FirebaseUI-iOS/pull/1415), [#1416](https://github.com/firebase/FirebaseUI-iOS/pull/1416)).
- Reauthentication: `EmailReauthScreen`, `PhoneReauthScreen` and `EmailLinkReauthScreen` ([#1423](https://github.com/firebase/FirebaseUI-iOS/pull/1423)).
- Every public state initializer parameter has a default, so previews pass only what they need ([#1415](https://github.com/firebase/FirebaseUI-iOS/pull/1415)).

#### Email sign-up and links

- `withEmailSignIn(requireDisplayName:allowNewEmailAccounts:)` restores the v15 options to ask for a name on sign-up and to turn sign-up off. Both default to today's behaviour ([#1428](https://github.com/firebase/FirebaseUI-iOS/pull/1428)).
- An email sign-in link opened on a device that didn't request it asks for the email address instead of failing, as in v15. `forceSameDevice` keeps links on the requesting device, and sign-in links keep the app's own continue URL parameters ([#1429](https://github.com/firebase/FirebaseUI-iOS/pull/1429)).

### 🛠️ Bug Fixes

- Reauthenticating an MFA-enrolled user now asks for the second factor. Tapping Confirm used to do nothing visible ([#1419](https://github.com/firebase/FirebaseUI-iOS/pull/1419)).
- Email-link reauthentication completes when the link opens the app after a cold launch ([#1430](https://github.com/firebase/FirebaseUI-iOS/pull/1430)).
- Cancelled or abandoned email-link reauthentication no longer makes later sign-in links route to reauthentication ([#1431](https://github.com/firebase/FirebaseUI-iOS/pull/1431)).
- Signing in closes the signed-out screens, so an email sign-in link shows the signed-in screen instead of the send form ([#1438](https://github.com/firebase/FirebaseUI-iOS/pull/1438)).
- Sending a phone verification code shows progress and ignores repeated taps ([#1412](https://github.com/firebase/FirebaseUI-iOS/pull/1412)).
- Password recovery failures show the error alert instead of failing silently ([#1414](https://github.com/firebase/FirebaseUI-iOS/pull/1414)).

### 📦 Dependencies

- `googlesignin-ios` 10.1.0, `firebase-ios-sdk` 12.19.3 and `googleutilities` 8.1.5 ([#1427](https://github.com/firebase/FirebaseUI-iOS/pull/1427)).

### 🧰 Internal

- Faster SwiftUI Auth CI jobs ([#1426](https://github.com/firebase/FirebaseUI-iOS/pull/1426)).

**Full Changelog**: https://github.com/firebase/FirebaseUI-iOS/compare/v16.2.0...main
