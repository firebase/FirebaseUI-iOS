# FirebaseUI for SwiftUI

FirebaseUI for SwiftUI is a library built on top of Firebase Authentication that provides modern, SwiftUI-first sign-in flows for your app.

FirebaseUI for SwiftUI provides the following benefits:

- Opinionated default UI: add a complete sign-in flow with `AuthPickerView`.
- Customizable: use the built-in flow, render the default buttons in your own layout, or build a fully custom experience with `AuthService`.
- Anonymous account linking: optionally upgrade anonymous users instead of replacing them.
- Account management: built-in flows for sign-in, sign-up, password recovery, email link sign-in, reauthentication, and account management.
- Multiple providers: email/password, email link, phone authentication, Apple, Google, Facebook, Twitter, and generic OAuth/OIDC providers.
- Modern auth features: built-in support for multi-factor authentication (MFA) and async/await APIs.

## Before you begin

FirebaseUI authentication is now delivered as Swift Package Manager packages for SwiftUI apps.

1. Add Firebase to your Apple project by following the [Firebase iOS setup guide](https://firebase.google.com/docs/ios/setup).
2. In Xcode, choose **File > Add Package Dependencies...**
3. Add `https://github.com/firebase/FirebaseUI-iOS`
4. Select `FirebaseAuthSwiftUI` and any provider packages you want to use:
   - `FirebaseAppleSwiftUI`
   - `FirebaseGoogleSwiftUI`
   - `FirebaseFacebookSwiftUI`
   - `FirebasePhoneAuthSwiftUI`
   - `FirebaseTwitterSwiftUI`
   - `FirebaseOAuthSwiftUI`
5. Make sure your app targets iOS 17 or later.

Then configure Firebase when your app launches:

```swift
import FirebaseAuthSwiftUI
import FirebaseCore
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
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

## Set up sign-in methods

Before you can sign users in, enable the providers you want to support in **Authentication > Sign-in method** in the [Firebase console](https://console.firebase.google.com/u/0/project/_/authentication/providers).

### Email address and password

Enable the **Email/Password** provider in the Firebase console.

Add email sign-in to your `AuthService`:

```swift
 let authService = AuthService()
  .withEmailSignIn()
```

### Email link authentication

To use passwordless email link sign-in, configure `ActionCodeSettings` and pass it into `AuthConfiguration`.

```swift
let actionCodeSettings = ActionCodeSettings()
actionCodeSettings.handleCodeInApp = true
actionCodeSettings.url = URL(string: "https://yourapp.firebaseapp.com")

guard let bundleID = Bundle.main.bundleIdentifier else {
  fatalError("Missing bundle identifier for email link authentication setup.")
}

actionCodeSettings.setIOSBundleID(bundleID)

let configuration = AuthConfiguration(
  emailLinkSignInActionCodeSettings: actionCodeSettings
)

let authService = AuthService(configuration: configuration)
  .withEmailSignIn()
```

You must also:

1. Enable **Email link (passwordless sign-in)** in the Firebase console.
2. Add the link domain to **Authorized domains**.
3. If you build custom views, call `authService.handleSignInLink(url:)` when the link opens your app.

### Apple

To use Sign in with Apple:

1. Enable **Apple** in the Firebase console.
2. Add the **Sign in with Apple** capability in Xcode.
3. Follow the Firebase guide for [Sign in with Apple on Apple platforms](https://firebase.google.com/docs/auth/ios/apple).

Then register the provider:

```swift
 let authService = AuthService()
  .withAppleSignIn()
```

### Google

To use Google Sign-In:

1. Enable **Google** in the Firebase console.
2. Follow the Firebase guide for [Google Sign-In on Apple platforms](https://firebase.google.com/docs/auth/ios/google-signin).
3. Add your `REVERSED_CLIENT_ID` from `GoogleService-Info.plist` to **URL Types** in your Xcode target.

Then register the provider:

```swift
 let authService = AuthService()
  .withGoogleSignIn()
```

### Facebook

To use Facebook Login:

1. Enable **Facebook** in the Firebase console and add your Facebook App ID and App Secret.
2. Follow Facebook's iOS SDK setup instructions.
3. Add `fb{your-app-id}` to **URL Types** in your Xcode target.
4. Add `FacebookAppID` and `FacebookDisplayName` to `Info.plist`.
5. Enable Keychain Sharing in Xcode.

Then register the provider:

```swift
 let authService = AuthService()
  .withFacebookSignIn()
```

### Phone number

To use phone authentication:

1. Enable **Phone** in the Firebase console.
2. Configure APNs for your app.
3. Enable Push Notifications in Xcode.
4. Add your Firebase **Encoded App ID** as a URL scheme for reCAPTCHA fallback.

Phone auth also needs the APNs token and reCAPTCHA URL handlers shown in `Handle provider callbacks` below. Add those methods to the same `AppDelegate` you use for `FirebaseApp.configure()`.

Then register the provider:

```swift
 let authService = AuthService()
  .withPhoneSignIn()
```

### Twitter

To use Twitter Login:

1. Enable **Twitter** in the Firebase console.
2. Configure the provider credentials in Firebase.

Then register the provider:

```swift
 let authService = AuthService()
  .withTwitterSignIn()
```

### Generic OAuth and OIDC providers

FirebaseUI also supports built-in OAuth providers such as GitHub, Microsoft, and Yahoo, as well as custom OIDC providers configured in Firebase Authentication.

```swift
 let authService = AuthService()
  .withOAuthSignIn(OAuthProviderSwift.github())
  .withOAuthSignIn(OAuthProviderSwift.microsoft())
  .withOAuthSignIn(OAuthProviderSwift.yahoo())
```

For custom OIDC providers, configure the provider first in Firebase Authentication, then create an `OAuthProviderSwift` with your provider ID and button configuration:

```swift
let lineProvider = OAuthProviderSwift(
  providerId: "oidc.line",
  buttonLabel: "Sign in with LINE",
  displayName: "LINE",
  iconSystemName: "person.crop.circle.badge.checkmark",
  buttonBackgroundColor: .green,
  buttonForegroundColor: .white
)

let authService = AuthService()
  .withOAuthSignIn(lineProvider)
```

### Handle provider callbacks

If you use Google Sign-In, Facebook Login, phone authentication, or email link flows, merge the following imports and methods into the same `AppDelegate` you use for `FirebaseApp.configure()`.

```swift
import FacebookCore
import FirebaseAuth
import GoogleSignIn
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    #if DEBUG
    Auth.auth().setAPNSToken(deviceToken, type: .sandbox)
    #else
    Auth.auth().setAPNSToken(deviceToken, type: .prod)
    #endif
  }

  func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    if Auth.auth().canHandle(url) {
      return true
    }

    if ApplicationDelegate.shared.application(
      app,
      open: url,
      sourceApplication: options[.sourceApplication] as? String,
      annotation: options[.annotation]
    ) {
      return true
    }

    return GIDSignIn.sharedInstance.handle(url)
  }
}
```

## Sign in

To start the FirebaseUI sign-in flow, create an `AuthService`, register the providers you want, and pass it into `AuthPickerView`.

### Swift

```swift
import FirebaseAppleSwiftUI
import FirebaseAuthSwiftUI
import FirebaseGoogleSwiftUI
import SwiftUI

struct ContentView: View {
  let authService: AuthService

  init() {
    let configuration = AuthConfiguration(
      shouldAutoUpgradeAnonymousUsers: true,
      tosUrl: URL(string: "https://example.com/terms"),
      privacyPolicyUrl: URL(string: "https://example.com/privacy")
    )

    authService = AuthService(configuration: configuration)
      .withEmailSignIn()
      .withAppleSignIn()
      .withGoogleSignIn()
  }

  var body: some View {
    AuthPickerView {
      authenticatedContent
    }
    .environment(authService)
  }

  var authenticatedContent: some View {
    NavigationStack {
      VStack(spacing: 20) {
        if authService.authenticationState == .authenticated {
          Text("Authenticated")

          Button("Manage Account") {
            authService.isPresented = true
          }
          .buttonStyle(.bordered)

          Button("Sign Out") {
            Task {
              try? await authService.signOut()
            }
          }
          .buttonStyle(.borderedProminent)
        } else {
          Text("Not Authenticated")

          Button("Sign In") {
            authService.isPresented = true
          }
          .buttonStyle(.borderedProminent)
        }
      }
    }
    .onChange(of: authService.authenticationState) { _, newValue in
      if newValue != .authenticating {
        authService.isPresented = (newValue == .unauthenticated)
      }
    }
  }
}
```

When you use `AuthPickerView`, FirebaseUI handles the default authentication flow for you, including:

- Navigation between sign-in screens
- Password recovery and email link flows
- Account conflict handling
- Reauthentication for sensitive operations
- MFA resolution when enabled

If you want more control, you can skip `AuthPickerView` and call `AuthService` methods directly from your own views.

## Sign out

FirebaseUI provides an async sign-out method:

```swift
Task {
  try await authService.signOut()
}
```

## Customization

You can customize the authentication experience in a few different ways.

Use `AuthConfiguration` to configure behavior such as:

- Terms of service and privacy policy URLs
- Custom localized strings bundle
- Email link configuration
- Anonymous user upgrades
- MFA support

```swift
let configuration = AuthConfiguration(
  shouldAutoUpgradeAnonymousUsers: true,
  customStringsBundle: .main,
  tosUrl: URL(string: "https://example.com/terms"),
  privacyPolicyUrl: URL(string: "https://example.com/privacy"),
  mfaEnabled: true
)
```

If you want to keep the built-in buttons but use your own layout, call `authService.renderButtons()`.

If you want a fully custom experience, build your own views and call methods such as:

- `authService.signIn(_:)`
- `authService.signIn(email:password:)`
- `authService.createUser(email:password:)`
- `authService.verifyPhoneNumber(phoneNumber:)`
- `authService.signInWithPhoneNumber(verificationID:verificationCode:)`

You can also register your own provider button by conforming to `AuthProviderUI` and calling `authService.registerProvider(providerWithButton:)`.

## Next steps

- See `FirebaseSwiftUI/README.md` for the full API reference and advanced usage.
- See `samples/swiftui/FirebaseSwiftUISample` for a working example app.
- For provider-specific setup details, refer to the Firebase Authentication docs for the provider you are enabling.
