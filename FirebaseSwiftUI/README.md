# FirebaseUI for SwiftUI Documentation

## Table of Contents

1. [Installation](#installation)
2. [Getting Started](#getting-started)
3. [Usage with Default Views](#usage-with-default-views)
4. [Usage with Custom Views](#usage-with-custom-views)
5. [API Reference](#api-reference)

---

## Installation

### Using Swift Package Manager

1. Launch Xcode and open the project or workspace where you want to add FirebaseUI for SwiftUI.
2. In the menu bar, go to: **File > Add Package Dependencies...**
3. Enter the Package URL: `https://github.com/firebase/FirebaseUI-iOS`
4. In the **Dependency Rule** dropdown, select **Exact Version** and set the version to the latest in the resulting text input.
5. Select the targets you wish to add to your app. The available SwiftUI packages are:
   - **FirebaseAuthSwiftUI** (required - includes Email auth provider)
   - **FirebaseAppleSwiftUI** (Sign in with Apple)
   - **FirebaseGoogleSwiftUI** (Sign in with Google)
   - **FirebaseFacebookSwiftUI** (Sign in with Facebook)
   - **FirebasePhoneAuthSwiftUI** (Phone authentication)
   - **FirebaseTwitterSwiftUI** (Sign in with Twitter)
   - **FirebaseOAuthSwiftUI** (Generic OAuth providers like GitHub, Microsoft, Yahoo)
6. Press the **Add Packages** button to complete installation.

### Platform Requirements

- **Minimum iOS Version**: iOS 17+
- **Swift Version**: Swift 6.0+

---

## Getting Started

### Basic Setup

Before using FirebaseUI for SwiftUI, you need to configure Firebase in your app:

1. Follow steps 2, 3 & 5 in [adding Firebase to your iOS app](https://firebase.google.com/docs/ios/setup).
2. Update your app entry point:

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

---

## Usage with Default Views

FirebaseUI for SwiftUI provides `AuthPickerView`, a pre-built, opinionated authentication UI that handles the entire authentication flow for you. This is the easiest way to add authentication to your app.

### Minimal Example

Here's a minimal example using the default views with email authentication:

```swift
import FirebaseAuthSwiftUI
import SwiftUI

struct ContentView: View {
  let authService: AuthService

  init() {
    let configuration = AuthConfiguration()
    
    authService = AuthService(configuration: configuration)
      .withEmailSignIn()
  }

  var body: some View {
    AuthPickerView {
      // Your authenticated app content goes here
      Text("Welcome to your app!")
    }
    .environment(authService)
  }
}
```

### Full-Featured Example

Here's a more complete example with multiple providers and configuration options:

```swift
import FirebaseAppleSwiftUI
import FirebaseAuthSwiftUI
import FirebaseFacebookSwiftUI
import FirebaseGoogleSwiftUI
import FirebaseOAuthSwiftUI
import FirebasePhoneAuthSwiftUI
import FirebaseTwitterSwiftUI
import SwiftUI

struct ContentView: View {
  let authService: AuthService

  init() {
    // Configure email link sign-in
    let actionCodeSettings = ActionCodeSettings()
    actionCodeSettings.handleCodeInApp = true
    actionCodeSettings.url = URL(string: "https://yourapp.firebaseapp.com")
    actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
    
    // Create configuration with options
    let configuration = AuthConfiguration(
      shouldAutoUpgradeAnonymousUsers: true,
      tosUrl: URL(string: "https://example.com/tos"),
      privacyPolicyUrl: URL(string: "https://example.com/privacy"),
      emailLinkSignInActionCodeSettings: actionCodeSettings,
      mfaEnabled: true
    )

    // Initialize AuthService with multiple providers
    authService = AuthService(configuration: configuration)
      .withEmailSignIn()
      .withAppleSignIn()
      .withGoogleSignIn()
      .withFacebookSignIn()
      .withPhoneSignIn()
      .withTwitterSignIn()
      .withOAuthSignIn(OAuthProviderSwift.github())
      .withOAuthSignIn(OAuthProviderSwift.microsoft())
      .withOAuthSignIn(OAuthProviderSwift.yahoo())
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
      .navigationTitle("My App")
    }
    .onChange(of: authService.authenticationState) { _, newValue in
      // Automatically show auth UI when not authenticated
      if newValue != .authenticating {
        authService.isPresented = (newValue == .unauthenticated)
      }
    }
  }
}
```

### How Default Views Work

When you use `AuthPickerView`, you get:

1. **Sheet Presentation**: Authentication UI appears as a modal sheet
2. **Built-in Navigation**: Automatic navigation between sign-in, password recovery, MFA, email link, and phone verification screens
3. **Authentication State Management**: Automatically switches between auth UI and your content based on `authService.authenticationState`
4. **Control via `isPresented`**: Control when the auth sheet appears by setting `authService.isPresented = true/false`

### Opinionated Behaviors in Default Views

The default `AuthPickerView` handles several complex scenarios automatically:

#### 1. **Account Conflict Resolution**

When an account conflict occurs (e.g., signing in with a credential that's already linked to another account), `AuthPickerView` automatically handles it:

- **Anonymous Upgrade Conflicts**: If `shouldAutoUpgradeAnonymousUsers` is enabled and a conflict occurs during anonymous upgrade, the system automatically signs out the anonymous user and signs in with the new credential.
- **Other Conflicts**: For credential conflicts between non-anonymous accounts, the system stores the pending credential and attempts to link it after successful sign-in.

This is handled by the `AccountConflictModifier` applied at the NavigationStack level.

#### 2. **Multi-Factor Authentication (MFA)**

When MFA is enabled in your configuration:

- Automatically detects when MFA is required during sign-in
- Presents appropriate MFA resolution screens (SMS or TOTP)
- Handles MFA enrollment and management flows
- Supports both SMS-based and Time-based One-Time Password (TOTP) factors

#### 3. **Error Handling**

The default views include built-in error handling:

- Displays user-friendly error messages in alert dialogs
- Automatically filters out errors that are handled internally (e.g., cancellation errors, auto-handled conflicts)
- Uses localized error messages via `StringUtils`
- Errors are propagated through the `reportError` environment key

#### 4. **Email Link Sign-In**

When email link sign-in is configured:

- Automatically stores the email address in app storage
- Handles deep link navigation from email
- Manages the complete email verification flow
- Supports anonymous user upgrades via email link

#### 5. **Anonymous User Auto-Upgrade**

When `shouldAutoUpgradeAnonymousUsers` is enabled:

- Automatically attempts to link anonymous accounts with new sign-in credentials
- Preserves user data by upgrading instead of replacing anonymous sessions
- Handles upgrade conflicts gracefully

### Available Auth Methods in Default Views

The default views support:

- **Email/Password Authentication** (built into `FirebaseAuthSwiftUI`)
- **Email Link Authentication** (passwordless)
- **Phone Authentication** (SMS verification)
- **Sign in with Apple**
- **Sign in with Google**
- **Sign in with Facebook** (Classic and Limited Login depending on whether App Tracking Transparency is authorized)
- **Sign in with Twitter**
- **Generic OAuth Providers** (GitHub, Microsoft, Yahoo, or custom OIDC)

---

## Usage with Custom Views

If you need more control over the UI or navigation flow, you can build your own custom authentication views while still leveraging the `AuthService` for authentication logic.

### Approach 1: Custom Buttons with `registerProvider()`

For complete control over button appearance, you can create your own custom `AuthProviderUI` implementation that wraps any provider and returns your custom button view.

#### Creating a Custom Provider UI

Here's how to create a custom Twitter button as an example:

```swift
import FirebaseAuthSwiftUI
import FirebaseTwitterSwiftUI
import SwiftUI

// Step 1: Create your custom button view
struct CustomTwitterButton: View {
  let provider: TwitterProviderSwift
  @Environment(AuthService.self) private var authService
  @Environment(\.mfaHandler) private var mfaHandler

  var body: some View {
    Button {
      Task {
        do {
          let outcome = try await authService.signIn(provider)

          // Handle MFA if required
          if case let .mfaRequired(mfaInfo) = outcome,
             let onMFA = mfaHandler {
            onMFA(mfaInfo)
          }
        } catch {
          // Do Something Else
        }
      }
    } label: {
      HStack { // Your custom icon
        Text("Sign in with Twitter")
          .fontWeight(.semibold)
      }
      .frame(maxWidth: .infinity)
      .padding()
      .background(
        LinearGradient(
          colors: [Color.blue, Color.cyan],
          startPoint: .leading,
          endPoint: .trailing
        )
      )
      .foregroundColor(.white)
      .cornerRadius(12)
      .shadow(radius: 4)
    }
  }
}

// Step 2: Create a custom AuthProviderUI wrapper
class CustomTwitterProviderAuthUI: AuthProviderUI {
  private let typedProvider: TwitterProviderSwift
  var provider: AuthProviderSwift { typedProvider }
  let id: String = "twitter.com"

  init(provider: TwitterProviderSwift = TwitterProviderSwift()) {
    typedProvider = provider
  }

  @MainActor func authButton() -> AnyView {
    AnyView(CustomTwitterButton(provider: typedProvider))
  }
}

// Step 3: Use it in your app
struct ContentView: View {
  let authService: AuthService

  init() {
    let configuration = AuthConfiguration()
    authService = AuthService(configuration: configuration)

    // Register your custom provider UI
    authService.registerProvider(
      providerWithButton: CustomTwitterProviderAuthUI()
    )
    authService.isPresented = true
  }

  var body: some View {
    AuthPickerView {
      usersApp
    }
    .environment(authService)
  }

  var usersApp: some View {
    NavigationStack {
      VStack {
        Button {
          authService.isPresented = true
        } label: {
          Text("Authenticate")
        }
      }
    }
  }
}
```

#### Simplified Custom Button Example

You can also create simpler custom buttons for any provider:

```swift
import FirebaseAuthSwiftUI
import FirebaseGoogleSwiftUI
import FirebaseAppleSwiftUI
import SwiftUI

// Custom Google Provider UI
class CustomGoogleProviderAuthUI: AuthProviderUI {
  private let typedProvider: GoogleProviderSwift
  var provider: AuthProviderSwift { typedProvider }
  let id: String = "google.com"
  
  init() {
    typedProvider = GoogleProviderSwift()
  }
  
  @MainActor func authButton() -> AnyView {
    AnyView(CustomGoogleButton(provider: typedProvider))
  }
}

struct CustomGoogleButton: View {
  let provider: GoogleProviderSwift
  @Environment(AuthService.self) private var authService
  
  var body: some View {
    Button {
      Task {
        try? await authService.signIn(provider)
      }
    } label: {
      HStack {
        Image(systemName: "g.circle.fill")
        Text("My Custom Google Button")
      }
      .frame(maxWidth: .infinity)
      .padding()
      .background(Color.purple) // Your custom color
      .foregroundColor(.white)
      .cornerRadius(10)
    }
  }
}

// Then use it
struct ContentView: View {
  let authService: AuthService
  
  init() {
    let configuration = AuthConfiguration()
    authService = AuthService(configuration: configuration)
      .withAppleSignIn() // Use default Apple button
    
    // Use custom Google button
    authService.registerProvider(
      providerWithButton: CustomGoogleProviderAuthUI()
    )
  }
  
  var body: some View {
    AuthPickerView {
      Text("App Content")
    }
    .environment(authService)
  }
}
```

This approach works for all providers: Google, Apple, Twitter, Facebook, Phone, and OAuth providers. Simply create your custom button view and wrap it in a class conforming to `AuthProviderUI`.

### Approach 2: Default Buttons with Custom Views

You can use `AuthService.renderButtons()` and bypass `AuthPickerView` to render the default authentication buttons while providing your own layout and navigation:

```swift
import FirebaseAuthSwiftUI
import FirebaseGoogleSwiftUI
import FirebaseAppleSwiftUI
import SwiftUI

struct CustomAuthView: View {
  @Environment(AuthService.self) private var authService

  var body: some View {
    VStack(spacing: 30) {
      // Your custom logo/branding
      Image("app-logo")
        .resizable()
        .frame(width: 150, height: 150)
      
      Text("Welcome to My App")
        .font(.largeTitle)
        .fontWeight(.bold)
      
      Text("Sign in to continue")
        .font(.subheadline)
        .foregroundStyle(.secondary)
      
      // Render default auth buttons
      authService.renderButtons(spacing: 12)
        .padding()
    }
    .padding()
  }
}

struct ContentView: View {
  init() {
    let configuration = AuthConfiguration()
    
    authService = AuthService(configuration: configuration)
      .withGoogleSignIn()
      .withAppleSignIn()
  }
  
  let authService: AuthService

  var body: some View {
    NavigationStack {
      if authService.authenticationState == .authenticated {
        Text("Authenticated!")
      } else {
        CustomAuthView()
      }
    }
    .environment(authService)
  }
}
```

### Approach 3: Custom Views with Custom Navigation

For complete control over the entire flow, you can bypass `AuthPickerView` and build your own navigation system:

```swift
import FirebaseAuth
import FirebaseAuthSwiftUI
import FirebaseGoogleSwiftUI
import SwiftUI

enum CustomAuthRoute {
  case signIn
  case phoneVerification
  case mfaResolution
}

struct ContentView: View {
  private let authService: AuthService
  @State private var navigationPath: [CustomAuthRoute] = []
  @State private var errorMessage: String?

  init() {
    let configuration = AuthConfiguration()
    self.authService = AuthService(configuration: configuration)
      .withGoogleSignIn()
      .withPhoneSignIn()
  }

  var body: some View {
    NavigationStack(path: $navigationPath) {
      Group {
        if authService.authenticationState == .authenticated {
          authenticatedView
        } else {
          customSignInView
        }
      }
      .navigationDestination(for: CustomAuthRoute.self) { route in
        switch route {
        case .signIn:
          customSignInView
        case .phoneVerification:
          customPhoneVerificationView
        case .mfaResolution:
          customMFAView
        }
      }
    }
    .environment(authService)
    .alert("Error", isPresented: .constant(errorMessage != nil)) {
      Button("OK") {
        errorMessage = nil
      }
    } message: {
      Text(errorMessage ?? "")
    }
  }

  var customSignInView: some View {
    VStack(spacing: 20) {
      Text("Custom Sign In")
        .font(.title)
      
      Button("Sign in with Google") {
        Task {
          do {
            let provider = GoogleProviderSwift(clientID: Auth.auth().app?.options.clientID ?? "")
            let outcome = try await authService.signIn(provider)
            
            // Handle MFA if required
            if case .mfaRequired = outcome {
              navigationPath.append(.mfaResolution)
            }
          } catch {
            errorMessage = error.localizedDescription
          }
        }
      }
      .buttonStyle(.borderedProminent)
      
      Button("Phone Sign In") {
        navigationPath.append(.phoneVerification)
      }
      .buttonStyle(.bordered)
    }
    .padding()
  }

  var customPhoneVerificationView: some View {
    Text("Custom Phone Verification View")
    // Implement your custom phone auth UI here
  }

  var customMFAView: some View {
    Text("Custom MFA Resolution View")
    // Implement your custom MFA UI here
  }

  var authenticatedView: some View {
    VStack(spacing: 20) {
      Text("Welcome!")
      Text("Email: \(authService.currentUser?.email ?? "N/A")")
      
      Button("Sign Out") {
        Task {
          try? await authService.signOut()
        }
      }
      .buttonStyle(.borderedProminent)
    }
  }
}
```

### Important Considerations for Custom Views

When building custom views, you need to handle several things yourself that `AuthPickerView` handles automatically:

1. **Account Conflicts**: Implement your own conflict resolution strategy using `AuthServiceError.accountConflict`
2. **MFA Handling**: Check `SignInOutcome` for `.mfaRequired` and handle MFA resolution manually
3. **Anonymous User Upgrades**: Handle the linking of anonymous accounts if `shouldAutoUpgradeAnonymousUsers` is enabled
4. **Navigation State**: Manage navigation between different auth screens (phone verification, password recovery, etc.)
5. **Loading States**: Show loading indicators during async authentication operations by observing `authService.authenticationState`

### Custom OAuth Providers

You can create custom OAuth providers for services beyond the built-in ones:

> **⚠️ Important:** OIDC (OpenID Connect) providers must be configured in your Firebase project's Authentication settings before they can be used. In the Firebase Console, go to **Authentication → Sign-in method** and add your OIDC provider with the required credentials (Client ID, Client Secret, Issuer URL). You must also register the OAuth redirect URI provided by Firebase in your provider's developer console. See the [Firebase OIDC documentation](https://firebase.google.com/docs/auth/ios/openid-connect) for detailed setup instructions.

```swift
import FirebaseAuthSwiftUI
import FirebaseOAuthSwiftUI
import SwiftUI

struct ContentView: View {
  let authService: AuthService

  init() {
    let configuration = AuthConfiguration()
    
    authService = AuthService(configuration: configuration)
      .withOAuthSignIn(
        OAuthProviderSwift(
          providerId: "oidc.line",  // LINE OIDC provider
          scopes: ["profile", "openid", "email"],  // LINE requires these scopes
          displayName: "Sign in with LINE",
          buttonIcon: Image("line-logo"),
          buttonBackgroundColor: .green,
          buttonForegroundColor: .white
        )
      )
      .withOAuthSignIn(
        OAuthProviderSwift(
          providerId: "oidc.custom-provider",
          scopes: ["profile", "openid"],
          displayName: "Sign in with Custom",
          buttonIcon: Image(systemName: "person.circle"),
          buttonBackgroundColor: .purple,
          buttonForegroundColor: .white
        )
      )
  }

  var body: some View {
    AuthPickerView {
      Text("App Content")
    }
    .environment(authService)
  }
}
```

---

## API Reference

### AuthConfiguration

The `AuthConfiguration` struct allows you to customize the behavior of the authentication flow.

```swift
public struct AuthConfiguration {
  public init(
    logo: ImageResource? = nil,
    languageCode: String? = nil,
    shouldHideCancelButton: Bool = false,
    interactiveDismissEnabled: Bool = true,
    shouldAutoUpgradeAnonymousUsers: Bool = false,
    customStringsBundle: Bundle? = nil,
    tosUrl: URL? = nil,
    privacyPolicyUrl: URL? = nil,
    emailLinkSignInActionCodeSettings: ActionCodeSettings? = nil,
    verifyEmailActionCodeSettings: ActionCodeSettings? = nil,
    mfaEnabled: Bool = false,
    allowedSecondFactors: Set<SecondFactorType> = [.sms, .totp],
    mfaIssuer: String = "Firebase Auth"
  )
}
```

#### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `logo` | `ImageResource?` | `nil` | Custom logo to display in the authentication UI. If not provided, the default Firebase logo is used. |
| `languageCode` | `String?` | `nil` | Language code for localized strings (e.g., "en", "es", "fr"). If not provided, uses system language. |
| `shouldHideCancelButton` | `Bool` | `false` | When `true`, hides the cancel button in auth flows, preventing users from dismissing the UI. Useful for mandatory authentication. |
| `interactiveDismissEnabled` | `Bool` | `true` | When `false`, prevents users from dismissing auth sheets by swiping down. |
| `shouldAutoUpgradeAnonymousUsers` | `Bool` | `false` | When `true`, automatically links anonymous user accounts with new sign-in credentials, preserving any data associated with the anonymous session. |
| `customStringsBundle` | `Bundle?` | `nil` | Custom bundle for string localizations. Allows you to override default strings with your own translations. |
| `tosUrl` | `URL?` | `nil` | URL to your Terms of Service. When both `tosUrl` and `privacyPolicyUrl` are set, links are displayed in the auth UI. |
| `privacyPolicyUrl` | `URL?` | `nil` | URL to your Privacy Policy. When both `tosUrl` and `privacyPolicyUrl` are set, links are displayed in the auth UI. |
| `emailLinkSignInActionCodeSettings` | `ActionCodeSettings?` | `nil` | Configuration for email link (passwordless) sign-in. Must be set to use email link authentication. |
| `verifyEmailActionCodeSettings` | `ActionCodeSettings?` | `nil` | Configuration for email verification. Used when sending verification emails to users. |
| `mfaEnabled` | `Bool` | `false` | Enables Multi-Factor Authentication support. When enabled, users can enroll in and use MFA. |
| `allowedSecondFactors` | `Set<SecondFactorType>` | `[.sms, .totp]` | Set of allowed MFA factor types. Options are `.sms` (phone-based) and `.totp` (authenticator app). |
| `mfaIssuer` | `String` | `"Firebase Auth"` | The issuer name displayed in TOTP authenticator apps when users enroll. |

#### Notes

- Both `tosUrl` and `privacyPolicyUrl` must be set for the links to appear in the UI.
- `emailLinkSignInActionCodeSettings` is **required** if you want to use email link sign-in. The `ActionCodeSettings` must have:
  - `handleCodeInApp = true`
  - A valid `url` 
  - iOS bundle ID configured via `setIOSBundleID()`

---

### AuthService

The main service class that manages authentication state and operations.

#### Initialization

```swift
public init(
  configuration: AuthConfiguration = AuthConfiguration(),
  auth: Auth = Auth.auth()
)
```

Creates a new `AuthService` instance.

**Parameters:**
- `configuration`: Configuration for auth behavior (default: `AuthConfiguration()`)
- `auth`: Firebase Auth instance to use (default: `Auth.auth()`)

---

#### Configuring Providers

##### Email Authentication

```swift
public func withEmailSignIn(_ provider: EmailProviderSwift? = nil, onTap: @escaping () -> Void = {}) -> AuthService
```

Enables email authentication and will render email sign-in directly within the AuthPickerView (default Views), email link sign-in is rendered as a button. When calling `AuthService.renderButtons()`, email link sign-in button is rendered. `onTap` custom callback (i.e where to navigate when tapped) allows user to control what happens when tapped. Default behavior in AuthPickerView is to push the user to email link sign-in default View.

**Parameters:**
- `provider`: An optional instance of `EmailProviderSwift`. If not provided, a default instance will be created.
- `onTap`: A callback that will be executed when the email button is tapped.

**Example:**

```swift
authService
  .withEmailSignIn()

// or

authService
  .withEmailSignIn() {
    // navigate to email sign-in screen logic
  }
```

---

##### Phone Authentication

```swift
public func withPhoneSignIn(onTap: @escaping () -> Void = {}) -> AuthService
```

Enables phone number authentication with SMS verification and will register a phone button that is rendered in AuthPickerView (default Views) or can be rendered in custom Views by calling `AuthService.renderButtons()`. `onTap` custom callback (i.e where to navigate when tapped) allows user to control what happens when tapped. Default behavior in AuthPickerView is to push the user to phone sign-in default View.

**Parameters:**
- `onTap`: A callback that will be executed when the phone button is tapped.

**Example:**

```swift
authService
  .withPhoneSignIn()

// or

authService
  .withPhoneSignIn() {
    // navigate to phone sign-in screen logic
  }
```

---

##### Sign in with Apple

```swift
// Available when importing FirebaseAppleSwiftUI
public func withAppleSignIn(_ provider: AppleProviderSwift? = nil) -> AuthService
```

Enables Sign in with Apple authentication and will register an apple button that is rendered in `AuthPickerView` (default Views) or can be rendered in custom Views by calling `AuthService.renderButtons()`.

**Parameters:**
- `provider`: An optional instance of `AppleProviderSwift`. If not provided, a default instance will be created.

**Example:**

```swift
authService
  .withAppleSignIn()
```

---

##### Sign in with Google

```swift
// Available when importing FirebaseGoogleSwiftUI
public func withGoogleSignIn(_ provider: GoogleProviderSwift? = nil) -> AuthService
```

Enables Sign in with Google authentication and will register a Google button that is rendered in AuthPickerView (default Views) or can be rendered in custom Views by calling `AuthService.renderButtons()`.

**Parameters:**
- `provider`: An optional instance of `GoogleProviderSwift`. If not provided, a default instance will be created using the client ID from Firebase configuration.

**Example:**

```swift
authService
  .withGoogleSignIn()
```

---

##### Sign in with Facebook

```swift
// Available when importing FirebaseFacebookSwiftUI
public func withFacebookSignIn(_ provider: FacebookProviderSwift? = nil) -> AuthService
```

Enables Sign in with Facebook authentication and will register a Facebook button that is rendered in AuthPickerView (default Views) or can be rendered in custom Views by calling `AuthService.renderButtons()`.

**Parameters:**
- `provider`: An optional instance of `FacebookProviderSwift()` for classic login or `FacebookProviderSwift(useClassicLogin: false)` for limited login. If not provided, a default instance with classic login will be created.

**Example:**

```swift
authService
  .withFacebookSignIn()
```

---

##### Sign in with Twitter

```swift
// Available when importing FirebaseTwitterSwiftUI
public func withTwitterSignIn(_ provider: TwitterProviderSwift? = nil) -> AuthService
```

Enables Sign in with Twitter authentication and will register a Twitter button that is rendered in AuthPickerView (default Views) or can be rendered in custom Views by calling `AuthService.renderButtons()`.

**Parameters:**
- `provider`: An optional instance of `TwitterProviderSwift`. If not provided, a default instance will be created.

**Example:**

```swift
authService
  .withTwitterSignIn()
```

---

##### Generic OAuth Providers

```swift
// Available when importing FirebaseOAuthSwiftUI
public func withOAuthSignIn(_ provider: OAuthProviderSwift) -> AuthService
```

Enables authentication with generic OAuth/OIDC providers and will register an OAuth button that is rendered in AuthPickerView (default Views) or can be rendered in custom Views by calling `AuthService.renderButtons()`.

**Built-in Providers:**
- `OAuthProviderSwift.github()`
- `OAuthProviderSwift.microsoft()`
- `OAuthProviderSwift.yahoo()`

**Custom Provider:**

```swift
OAuthProviderSwift(
  providerId: String,
  displayName: String,
  buttonIcon: Image,
  buttonBackgroundColor: Color,
  buttonForegroundColor: Color
)
```

**Example:**

```swift
authService
  .withOAuthSignIn(OAuthProviderSwift.github())
  .withOAuthSignIn(OAuthProviderSwift.microsoft())
  .withOAuthSignIn(
    OAuthProviderSwift(
      providerId: "oidc.custom-provider",
      displayName: "Sign in with Custom",
      buttonIcon: Image("custom-logo"),
      buttonBackgroundColor: .blue,
      buttonForegroundColor: .white
    )
  )
```

---

#### Custom Provider Registration

```swift
public func registerProvider(providerWithButton: AuthProviderUI)
```

Registers a custom authentication provider that conforms to `AuthProviderUI`.

**Parameters:**
- `providerWithButton`: A custom provider implementing the `AuthProviderUI` protocol.

**Example:**

```swift
let customProvider = MyCustomProvider()
authService.registerProvider(providerWithButton: customProvider)
```

---

#### Rendering Authentication Buttons

```swift
public func renderButtons(spacing: CGFloat = 16) -> AnyView
```

Renders all registered authentication provider buttons as a vertical stack.

**Parameters:**
- `spacing`: Vertical spacing between buttons (default: 16)

**Returns:** An `AnyView` containing all auth buttons.

**Example:**

```swift
VStack {
  Text("Choose a sign-in method")
  authService.renderButtons(spacing: 12)
}
```

---

#### Authentication Operations

##### Sign In with Credential

```swift
public func signIn(_ provider: CredentialAuthProviderSwift) async throws -> SignInOutcome
```

Signs in using a provider that conforms to `CredentialAuthProviderSwift`.

**Parameters:**
- `provider`: The authentication provider to use.

**Returns:** `SignInOutcome` - either `.signedIn(AuthDataResult?)` or `.mfaRequired(MFARequired)`

**Throws:** `AuthServiceError` or Firebase Auth errors

**Example:**

```swift
Task {
  do {
    let outcome = try await authService.signIn(GoogleProviderSwift())
    switch outcome {
    case .signedIn(let result):
      print("Signed in: \(result?.user.email ?? "")")
    case .mfaRequired(let mfaInfo):
      // Handle MFA resolution
      print("MFA required: \(mfaInfo)")
    }
  } catch {
    print("Sign in error: \(error)")
  }
}
```

---

##### Sign In with Email/Password

```swift
public func signIn(email: String, password: String) async throws -> SignInOutcome
```

Signs in using email and password credentials.

**Parameters:**
- `email`: User's email address
- `password`: User's password

**Returns:** `SignInOutcome`

**Throws:** `AuthServiceError` or Firebase Auth errors

---

##### Create User with Email/Password

```swift
public func createUser(email email: String, password: String) async throws -> SignInOutcome
```

Creates a new user account with email and password.

**Parameters:**
- `email`: New user's email address
- `password`: New user's password

**Returns:** `SignInOutcome`

**Throws:** `AuthServiceError` or Firebase Auth errors

---

##### Sign Out

```swift
public func signOut() async throws
```

Signs out the current user.

**Throws:** Firebase Auth errors

**Example:**

```swift
Button("Sign Out") {
  Task {
    try await authService.signOut()
  }
}
```

---

##### Link Accounts

```swift
public func linkAccounts(credentials credentials: AuthCredential) async throws
```

Links a new authentication method to the current user's account.

**Parameters:**
- `credentials`: The credential to link

**Throws:** `AuthServiceError` or Firebase Auth errors

---

#### Email Link (Passwordless) Authentication

##### Send Email Sign-In Link

```swift
public func sendEmailSignInLink(email: String) async throws
```

Sends a sign-in link to the specified email address.

**Parameters:**
- `email`: Email address to send the link to

**Throws:** `AuthServiceError` or Firebase Auth errors

**Requirements:** `emailLinkSignInActionCodeSettings` must be configured in `AuthConfiguration`

---

##### Handle Sign-In Link

```swift
public func handleSignInLink(url url: URL) async throws
```

Handles the sign-in flow when the user taps the email link.

**Parameters:**
- `url`: The deep link URL from the email

**Throws:** `AuthServiceError` or Firebase Auth errors

---

#### Phone Authentication

##### Verify Phone Number

```swift
public func verifyPhoneNumber(phoneNumber: String) async throws -> String
```

Sends a verification code to the specified phone number.

**Parameters:**
- `phoneNumber`: Phone number in E.164 format (e.g., "+15551234567")

**Returns:** Verification ID to use when verifying the code

**Throws:** Firebase Auth errors

---

##### Sign In with Phone Number

```swift
public func signInWithPhoneNumber(
  verificationID: String,
  verificationCode: String
) async throws
```

Signs in using a phone number and verification code.

**Parameters:**
- `verificationID`: The verification ID returned from `verifyPhoneNumber()`
- `verificationCode`: The SMS code received by the user

**Throws:** `AuthServiceError` or Firebase Auth errors

---

#### User Profile Management

##### Update Display Name

```swift
public func updateUserDisplayName(name: String) async throws
```

Updates the current user's display name.

**Parameters:**
- `name`: New display name

**Throws:** `AuthServiceError.noCurrentUser` or Firebase Auth errors

---

##### Update Photo URL

```swift
public func updateUserPhotoURL(url: URL) async throws
```

Updates the current user's photo URL.

**Parameters:**
- `url`: URL to the user's profile photo

**Throws:** `AuthServiceError.noCurrentUser` or Firebase Auth errors

---

##### Update Password

```swift
public func updatePassword(to password: String) async throws
```

Updates the current user's password. May require recent authentication.

**Parameters:**
- `password`: New password

**Throws:** `AuthServiceError.noCurrentUser` or Firebase Auth errors

---

##### Send Email Verification

```swift
public func sendEmailVerification() async throws
```

Sends a verification email to the current user's email address.

**Throws:** `AuthServiceError.noCurrentUser` or Firebase Auth errors

---

##### Delete User

```swift
public func deleteUser() async throws
```

Deletes the current user's account. May require recent authentication.

**Throws:** `AuthServiceError.noCurrentUser` or Firebase Auth errors

---

#### Multi-Factor Authentication (MFA)

##### Start MFA Enrollment

```swift
public func startMfaEnrollment(
  type: SecondFactorType,
  accountName: String? = nil,
  issuer: String? = nil
) async throws -> EnrollmentSession
```

Initiates enrollment for a second factor.

**Parameters:**
- `type`: Type of second factor (`.sms` or `.totp`)
- `accountName`: Account name for TOTP (defaults to user's email)
- `issuer`: Issuer name for TOTP (defaults to `configuration.mfaIssuer`)

**Returns:** `EnrollmentSession` containing enrollment information

**Throws:** `AuthServiceError` if MFA is not enabled or factor type not allowed

**Requirements:** `mfaEnabled` must be `true` in `AuthConfiguration`

---

##### Send SMS Verification for Enrollment

```swift
public func sendSmsVerificationForEnrollment(
  session: EnrollmentSession,
  phoneNumber: String
) async throws -> String
```

Sends SMS verification code during MFA enrollment (for SMS-based second factor).

**Parameters:**
- `session`: The enrollment session from `startMfaEnrollment()`
- `phoneNumber`: Phone number to enroll (E.164 format)

**Returns:** Verification ID for completing enrollment

**Throws:** `AuthServiceError`

---

##### Complete MFA Enrollment

```swift
public func completeEnrollment(
  session: EnrollmentSession,
  verificationId: String?,
  verificationCode: String,
  displayName: String
) async throws
```

Completes the MFA enrollment process.

**Parameters:**
- `session`: The enrollment session
- `verificationId`: Verification ID (required for SMS, ignored for TOTP)
- `verificationCode`: The verification code from SMS or TOTP app
- `displayName`: Display name for this MFA factor

**Throws:** `AuthServiceError`

---

##### Unenroll MFA Factor

```swift
public func unenrollMFA(_ factorUid: String) async throws -> [MultiFactorInfo]
```

Removes an MFA factor from the user's account.

**Parameters:**
- `factorUid`: UID of the factor to remove

**Returns:** Updated list of remaining enrolled factors

**Throws:** `AuthServiceError.noCurrentUser` or Firebase Auth errors

---

##### Resolve MFA Challenge (SMS)

```swift
public func resolveSmsChallenge(hintIndex: Int) async throws -> String
```

Sends SMS code for resolving an MFA challenge during sign-in.

**Parameters:**
- `hintIndex`: Index of the MFA hint to use

**Returns:** Verification ID for completing sign-in

**Throws:** `AuthServiceError`

---

##### Resolve Sign-In with MFA

```swift
public func resolveSignIn(
  code: String,
  hintIndex: Int,
  verificationId: String? = nil
) async throws
```

Completes sign-in by verifying the MFA code.

**Parameters:**
- `code`: The MFA code from SMS or TOTP app
- `hintIndex`: Index of the MFA hint being used
- `verificationId`: Verification ID (required for SMS, ignored for TOTP)

**Throws:** `AuthServiceError`

---

#### Public Properties

```swift
public let configuration: AuthConfiguration
```
The configuration used by this service.

---

```swift
public let auth: Auth
```
The Firebase Auth instance.

---

```swift
public var isPresented: Bool
```
Controls whether the authentication sheet is presented (when using `AuthPickerView`).

---

```swift
public var currentUser: User?
```
The currently signed-in Firebase user, or `nil` if not authenticated.

---

```swift
public var authenticationState: AuthenticationState
```
Current authentication state: `.unauthenticated`, `.authenticating`, or `.authenticated`.

---

```swift
public var authenticationFlow: AuthenticationFlow
```
Current flow type: `.signIn` or `.signUp`.

---

```swift
public private(set) var navigator: Navigator
```
Navigator for managing navigation routes in default views.

---

```swift
public var passwordPrompt: PasswordPromptCoordinator
```
A coordinator that manages password prompt dialogs during reauthentication flows for the email provider. 

Users can provide a custom `PasswordPromptCoordinator` instance when initializing `EmailProviderSwift` to customize password prompting behavior:

```swift
let customPrompt = PasswordPromptCoordinator()
authService.withEmailSignIn(EmailProviderSwift(passwordPrompt: customPrompt))
```

**Default Behavior:** If no custom coordinator is provided, a default `PasswordPromptCoordinator()` instance is created automatically. The default coordinator displays a modal sheet that prompts the user to enter their password when reauthentication is required for sensitive operations (e.g., updating email, deleting account).

---

```swift
public var authView: AuthView?
```
Currently displayed auth view (e.g., `.emailLink`, `.mfaResolution`).

---

### AuthPickerView

A pre-built view that provides complete authentication UI.

```swift
public struct AuthPickerView<Content: View>: View {
  public init(@ViewBuilder content: @escaping () -> Content = { EmptyView() })
}
```

**Parameters:**
- `content`: Your app's authenticated content, shown when user is signed in.

**Usage:**

```swift
AuthPickerView {
  // Your app content here
  Text("Welcome!")
}
.environment(authService)
```

**Behavior:**
- Presents authentication UI as a modal sheet controlled by `authService.isPresented`
- Automatically handles navigation between auth screens
- Includes built-in error handling and account conflict resolution
- Supports MFA flows automatically

---

### Enums and Types

#### AuthenticationState

```swift
public enum AuthenticationState {
  case unauthenticated
  case authenticating
  case authenticated
}
```

Represents the current authentication state.

---

#### SignInOutcome

```swift
public enum SignInOutcome {
  case mfaRequired(MFARequired)
  case signedIn(AuthDataResult?)
}
```

Result of a sign-in attempt. Either successful or requiring MFA.

---

#### SecondFactorType

```swift
public enum SecondFactorType {
  case sms
  case totp
}
```

Types of second factors for MFA.

---

#### AuthServiceError

```swift
public enum AuthServiceError: Error {
  case noCurrentUser
  case notConfiguredActionCodeSettings(String)
  case invalidEmailLink(String)
  case providerNotFound(String)
  case invalidCredentials(String)
  case multiFactorAuth(String)
  case simpleReauthenticationRequired(context: ReauthContext)
  case emailReauthenticationRequired(context: ReauthContext)
  case phoneReauthenticationRequired(context: ReauthContext)
  case accountConflict(AccountConflictContext)
}
```

Errors specific to `AuthService` operations.

**Reauthentication Errors:**
- `simpleReauthenticationRequired`: For providers like Google, Apple, Facebook, Twitter. Pass the context to `authService.reauthenticate(context:)`.
- `emailReauthenticationRequired`: For email/password authentication. Must handle password prompt externally.
- `phoneReauthenticationRequired`: For phone authentication. Must handle SMS verification flow externally.

---

### Best Practices

1. **Initialize AuthService in the parent view**: Create `AuthService` once and pass it down via the environment.

2. **Handle MFA outcomes**: Always check for `.mfaRequired` when calling sign-in methods if MFA is enabled.

3. **Use ActionCodeSettings for email link**: Email link sign-in requires proper `ActionCodeSettings` configuration.

4. **Test with anonymous users**: If using `shouldAutoUpgradeAnonymousUsers`, test the upgrade flow thoroughly.

5. **Observe authentication state**: Use `onChange(of: authService.authenticationState)` to react to authentication changes.

6. **Provider-specific setup**: Some providers (Google, Facebook) require additional configuration in AppDelegate or Info.plist. See the [sample app](https://github.com/firebase/FirebaseUI-iOS/tree/main/samples/swiftui) for examples.

---

## Additional Resources

- [Sample SwiftUI App](https://github.com/firebase/FirebaseUI-iOS/tree/main/samples/swiftui/FirebaseSwiftUIExample)
- [Firebase iOS Setup Guide](https://firebase.google.com/docs/ios/setup)
- [Firebase Authentication Documentation](https://firebase.google.com/docs/auth)
- [FirebaseUI-iOS GitHub Repository](https://github.com/firebase/FirebaseUI-iOS)

---

## Feedback

Please file feedback and issues in the [repository's issue tracker](https://github.com/firebase/FirebaseUI-iOS/issues).

