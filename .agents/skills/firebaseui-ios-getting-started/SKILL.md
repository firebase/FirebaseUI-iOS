---
name: firebaseui-ios-getting-started
description: Sets up FirebaseUI for SwiftUI authentication in a consumer iOS app. Use when adding FirebaseUI-iOS auth, FirebaseAuthSwiftUI, AuthPickerView, or default FirebaseUI SwiftUI sign-in views to an app repo.
---

# FirebaseUI iOS Getting Started

Use this skill when the user wants FirebaseUI for SwiftUI authentication added to their own iOS app repo. Assume the app should use FirebaseUI's default `AuthPickerView` unless the user asks for custom auth UI.

## Default Workflow

1. Inspect the app structure before editing:
   - Find the app target, bundle identifier, minimum iOS version, Swift version, package manager, and SwiftUI app entry point.
   - Find existing Firebase setup: `GoogleService-Info.plist`, `FirebaseApp.configure()`, Firebase package dependencies, URL types, entitlements, and any auth UI.
   - Identify the requested sign-in providers. If the user did not specify providers, default to email/password only.

2. Verify project requirements:
   - iOS deployment target must be iOS 17 or newer.
   - Swift language version must be Swift 6.0 or compatible with the FirebaseUI SwiftUI products.
   - The app must use a `GoogleService-Info.plist` downloaded from the user's Firebase project for the exact iOS bundle ID. Do not invent Firebase config values or reuse sample config.

3. Add dependencies from Swift Package Manager:
   - Package URL: `https://github.com/firebase/FirebaseUI-iOS`
   - Required product: `FirebaseAuthSwiftUI`
   - Add provider products only when the app uses them:
     - `FirebaseAppleSwiftUI` for Sign in with Apple
     - `FirebaseGoogleSwiftUI` for Google
     - `FirebaseFacebookSwiftUI` for Facebook
     - `FirebasePhoneAuthSwiftUI` for Phone
     - `FirebaseTwitterSwiftUI` for Twitter
     - `FirebaseOAuthSwiftUI` for GitHub, Microsoft, Yahoo, or custom OAuth/OIDC

4. Configure Firebase at app launch:
   - Import `FirebaseCore`.
   - Call `FirebaseApp.configure()` once during launch.
   - For SwiftUI apps, use an `UIApplicationDelegateAdaptor` if there is no existing app delegate.

5. Create one parent-owned `AuthService`:
   - Initialize it once in a parent view, not inside frequently recreated child views.
   - For SwiftUI views, keep the primary owner in `@State` so the `@Observable` service persists across view updates.
   - Chain provider registration methods that match the dependencies.
   - Inject it with `.environment(authService)` above `AuthPickerView` and any authenticated content that needs auth state.

6. Add the default auth surface:
   - Wrap authenticated app content in `AuthPickerView`.
   - Open the auth sheet by setting `authService.isPresented = true`.
   - Use `authService.authenticationState` and `authService.currentUser` for simple signed-in/signed-out UI.

7. Validate:
   - Run the repo's normal package resolution/build command, preferably for the real app scheme.
   - If there is no obvious command, inspect available schemes and run an iOS simulator build with `xcodebuild`.
   - Fix compile errors caused by missing imports, package products, deployment target, or app delegate URL handling.

## Minimal Default Views Pattern

Adapt names to the user's app. Preserve any existing app delegate and Firebase setup instead of duplicating it.

```swift
import FirebaseAuthSwiftUI
import FirebaseCore
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct YourApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}
```

```swift
import FirebaseAuth
import FirebaseAuthSwiftUI
import SwiftUI

struct ContentView: View {
  @State private var authService: AuthService

  init() {
    _authService = State(initialValue: AuthService(configuration: AuthConfiguration())
      .withEmailSignIn())
  }

  var body: some View {
    AuthPickerView {
      NavigationStack {
        VStack {
          Text("Authenticated")

          Button("Manage Account") {
            authService.isPresented = true
          }

          Button("Sign Out") {
            Task {
              try? await authService.signOut()
            }
          }
        }
      }
    }
    .environment(authService)
  }
}
```

## Provider Setup

Only add provider setup for providers the app actually uses.

- Email/password: add `FirebaseAuthSwiftUI`, call `.withEmailSignIn()`, and ensure Email/Password is enabled in Firebase Console Authentication.
- Google: add `FirebaseGoogleSwiftUI`, call `.withGoogleSignIn()`, add the `REVERSED_CLIENT_ID` from `GoogleService-Info.plist` as a URL scheme, and route incoming URLs through `GIDSignIn.sharedInstance.handle(url)` if the app delegate handles URLs manually.
- Apple: add `FirebaseAppleSwiftUI`, call `.withAppleSignIn()`, enable Sign in with Apple in the app's capabilities/entitlements and in Firebase Console.
- Facebook: add `FirebaseFacebookSwiftUI`, call `.withFacebookSignIn()`, add `fb{app-id}` as a URL scheme, set `FacebookAppID`, `FacebookClientToken`, and `FacebookDisplayName` in `Info.plist`, and forward launch/open-url events to `ApplicationDelegate.shared`.
- Phone: add `FirebasePhoneAuthSwiftUI`, call `.withPhoneSignIn()`, enable Phone in Firebase Console. If the app has an app delegate, preserve `Auth.auth().setAPNSToken(...)`, `Auth.auth().canHandleNotification(...)`, and `Auth.auth().canHandle(url)` handling when present.
- OAuth/OIDC: add `FirebaseOAuthSwiftUI`, call `.withOAuthSignIn(...)`, and ensure the provider is configured in Firebase Console before coding the app UI.
- Email link: configure `ActionCodeSettings` with `handleCodeInApp = true`, a valid URL/domain for the Firebase project, and `setIOSBundleID(Bundle.main.bundleIdentifier!)`.

## Gotchas

- Do not proceed silently if `GoogleService-Info.plist` is missing. Ask the user to download it from Firebase Console or confirm where it lives.
- Do not hardcode sample project Firebase values, reversed client IDs, Facebook app IDs, OAuth domains, or bundle IDs.
- Do not add every FirebaseUI provider by default. Each extra provider usually requires Firebase Console and `Info.plist` or entitlement setup.
- Do not create multiple `AuthService` instances for the same auth flow. It owns presentation and authentication state; in SwiftUI, prefer a parent-owned `@State` instance unless the app already has a stronger owner for auth state.
- If app code reads `authService.currentUser?.email`, `uid`, or other `User` members, import `FirebaseAuth` in addition to `FirebaseAuthSwiftUI`.
- `AuthPickerView` already handles default navigation, account conflict resolution, MFA flows, errors, and reauthentication for built-in default views. Avoid reimplementing those unless the user asks for custom views.
- For custom views, sensitive operations such as account deletion, password updates, and MFA unenrollment can throw reauthentication errors that default views would otherwise handle.
- FirebaseUI `14.x` does not include the `FirebaseAuthSwiftUI` product, so it is not a valid fallback for this SwiftUI workflow.
- If tagged FirebaseUI releases fail under Swift 6/Xcode with package-internal concurrency errors, check the upstream FirebaseUI SwiftUI docs/sample and consider the current `main` branch only after documenting the reproducibility tradeoff.
- If Xcode package resolution gets stuck on a stale DerivedData checkout, validate with a project-local package cache, for example `xcodebuild ... -clonedSourcePackagesDirPath SourcePackages`, then remove the generated `SourcePackages` directory before finishing.
- Xcode previews may fail if a preview instantiates a view that creates `AuthService` before `FirebaseApp.configure()` runs. Fix previews by calling `if FirebaseApp.app() == nil { FirebaseApp.configure() }` in the preview setup.

## Source References

Use these when details are needed beyond this skill:

- FirebaseUI SwiftUI docs: `https://github.com/firebase/FirebaseUI-iOS/blob/main/FirebaseSwiftUI/README.md`
- FirebaseUI SwiftUI sample: `https://github.com/firebase/FirebaseUI-iOS/tree/main/samples/swiftui/FirebaseSwiftUISample`
- Firebase iOS setup: `https://firebase.google.com/docs/ios/setup`
- Firebase Auth provider setup: `https://firebase.google.com/docs/auth`

## Validation Checklist

Before finishing, confirm:

- The FirebaseUI package products match the imported modules and `.with...SignIn()` calls.
- `GoogleService-Info.plist` is included in the app target resources, not just present on disk.
- `FirebaseApp.configure()` is called once before auth UI is used.
- URL schemes and app delegate URL handling match the enabled OAuth providers.
- The app builds for an iOS simulator or the repo's normal CI build command.
- The final response names any Firebase Console steps the user must complete manually.
