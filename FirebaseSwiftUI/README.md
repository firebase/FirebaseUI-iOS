# FirebaseUI for SwiftUI (Alpha release)

## Installation

1. Launch Xcode and open the project or workspace where you want to add the packages.
2. In the menu bar, go to: `File > Add Package Dependencies...`
3. Enter the Package URL: `https://github.com/firebase/FirebaseUI-iOS`
4. Select target(s) you wish to add to your app (currently `FirebaseAuthSwiftUI`, `FirebaseGoogleSwiftUI`, `FirebaseFacebookSwiftUI` and `FirebasePhoneAuthSwiftUI` are available). `FirebaseAuthSwiftUI` is required and contains the Email provider API.
5. Press the `Add Packages` button to complete installation.


## Getting started

1. Follow step 2, 3 & 5 on [adding Firebase to your SwiftUI app](https://firebase.google.com/docs/ios/setup).
2. You should now update your app entry point to look like this:

```swift
import FirebaseAuthSwiftUI
import FirebaseCore
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [
                     UIApplication.LaunchOptionsKey: Any
                   ]?) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct FirebaseSwiftUIExampleApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}

struct ContentView: View {
  let authService: AuthService

  init() {
    let configuration = AuthConfiguration()

    authService = AuthService(
      configuration: configuration,
    )
    .withEmailSignIn()
  }

  var body: some View {
    AuthPickerView().environment(authService)
  }
}
```

3. For a more complete example, see the [SwiftUI sample app](https://github.com/firebase/FirebaseUI-iOS/tree/main/samples/swiftui/FirebaseSwiftUIExample).

## Configuration options

You can create an `AuthConfiguration` instance and pass it to the `AuthService` as demonstrated above. Here are the options:

```swift
public struct AuthConfiguration {
  // hides cancel buttons when you don't want a flow to be interrupted
  let shouldHideCancelButton: Bool
  // stop users from being able to swipe away sheets/modal
  let interactiveDismissEnabled: Bool
  // automatically upgrade anonymous users so that they are linked with account being used to sign-in
  let shouldAutoUpgradeAnonymousUsers: Bool
  // custom string bundle for string localizations
  let customStringsBundle: Bundle?
  // terms of service URL
  let tosUrl: URL
  // privacy policy URL
  let privacyPolicyUrl: URL
  // action code settings for email sign in link
  let emailLinkSignInActionCodeSettings: ActionCodeSettings?
  // action code settings verifying email address
  let verifyEmailActionCodeSettings: ActionCodeSettings?

  public init(shouldHideCancelButton: Bool = false,
              interactiveDismissEnabled: Bool = true,
              shouldAutoUpgradeAnonymousUsers: Bool = false,
              customStringsBundle: Bundle? = nil,
              tosUrl: URL = URL(string: "https://example.com/tos")!,
              privacyPolicyUrl: URL = URL(string: "https://example.com/privacy")!,
              emailLinkSignInActionCodeSettings: ActionCodeSettings? = nil,
              verifyEmailActionCodeSettings: ActionCodeSettings? = nil)
}
```

## Configuring providers

1. Ensure the provider is installed from step 1 (e.g. if configuring Google provider, you need to install `FirebaseGoogleSwiftUI` package).
2. Ensure you have called the relevant API on `AuthService` to initialise provider. Example of Email and Google provider initialization:

```swift
let authService = AuthService()
    .withEmailSignIn()
    .withGoogleSignIn()
```

> Note: There may be additional setup for each provider typically in the AppDelegate. [See example app for setup.](https://github.com/firebase/FirebaseUI-iOS/tree/main/samples/swiftui/FirebaseSwiftUIExample) 


## API available for alpha release
1. General API
   - Auto upgrade anonymous user account linking (if configured).
   - Sign out
2. Email/Password
   - Sign-in/Create user
   - Password recovery
   - Email link sign-in
3. Google
   - Sign in with Google
4. Facebook
   1. Sign in with Facebook limited login
   2. Sign in with Facebook classic login 
5. Phone Auth
   - Verify phone number
   - Sign in with phone number 
6. User
   - Update password
   - Delete user
   - Verify email address


## Notes for Alpha release
1. Customization/theming for Views is not yet available.
2. The providers available are Email, Phone, Google and Facebook.
3. String localizations have been ported over and used where possible from the previous implementation, but new strings will only have English translations for the time being.
4. The UI has not been polished and is subject to change once design has been finalized.
