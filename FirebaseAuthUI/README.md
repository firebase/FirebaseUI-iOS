# FirebaseUI for iOS — Auth

FirebaseUI is an open-source library for iOS that provides simple, customizable UI
bindings on top of [Firebase](https://firebase.google.com) SDKs to eliminate
boilerplate code and promote best practices.

FirebaseUI provides a drop-in auth solution that handles the UI flows for
signing in users with email addresses and passwords, and federated identity
providers such as Google Sign-In and Facebook Login. It is built on top of
[Firebase Auth](https://firebase.google.com/docs/auth).

The FirebaseUI Auth component implement best practices for authentication on
mobile devices and websites, which can maximize sign-in and sign-up conversion
for your app. It also handles edge cases like account recovery and account
linking that can be security sensitive and error-prone to handle correctly.

FirebaseUI can be easily customized to fit in with the rest of your app's visual
style, and it is open source, so you aren't constrained in realizing the user
experience you want.

Compatible FirebaseUI Auth clients are also available for
[Android](https://github.com/firebase/firebaseui-android/tree/master/auth)
and [Web](https://github.com/firebase/firebaseui-web/).

## Table of Contents

1. [Installation](#installation)
1. [Usage instructions](#using-firebaseui-for-authentication)
1. [Customization](#customizing-firebaseui-for-authentication)

## Installation
### Importing FirebaseUI components for auth
Add the following to your `Podfile`:
```ruby
pod 'FirebaseUI/Auth'

pod 'FirebaseUI/Email'
pod 'FirebaseUI/Google'
pod 'FirebaseUI/Facebook'
pod 'FirebaseUI/Phone'
pod 'FirebaseUI/OAuth'
```

### Configuring sign-in providers
To use FirebaseUI to authenticate users you first need to configure each provider you want to use in
their own developer app settings. Please read the *Before you begin* section of the Firebase
Auth guides at the following links:

- [Email and password](https://firebase.google.com/docs/auth/ios/password-auth#before_you_begin)
- [Google](https://firebase.google.com/docs/auth/ios/google-signin#before_you_begin)
- [Facebook](https://firebase.google.com/docs/auth/ios/facebook-login#before_you_begin)
- [Phone](https://firebase.google.com/docs/auth/ios/phone-auth#before_you_begin)
- [Sign in with Apple](https://firebase.google.com/docs/auth/ios/apple#before_you_begin)
  - For Sign in with Apple, read the [Comply with Apple anonymized data requirements](https://firebase.google.com/docs/auth/ios/apple#comply-with-apple-anonymized-data-requirements) section as well. 

## Using FirebaseUI for Authentication

### Configuration

All operations, callbacks, UI customizations are done through an `FUIAuth`
instance. The `FUIAuth` instance associated with the default Firebase Auth
instance can be accessed as follows:

```swift
// Swift
import FirebaseUI

/* ... */

FirebaseApp.configure()
let authUI = FUIAuth.defaultAuthUI()
// You need to adopt a FUIAuthDelegate protocol to receive callback
authUI?.delegate = self
```

```objective-c
// Objective-C
@import FirebaseUI;

/* ... */

[FIRApp configure];
FUIAuth *authUI = [FUIAuth defaultAuthUI];
// You need to adopt a FUIAuthDelegate protocol to receive callback
authUI.delegate = self;
```

This instance can then be configured with the providers you wish to support:

```swift
// Swift
import FirebaseUI

/* ... */

let providers: [FUIAuthProvider] = [
  FUIEmailAuth(),
  FUIGoogleAuth(),
  FUIFacebookAuth(),
  FUIPhoneAuth(authUI: FUIAuth.defaultAuthUI()),
  FUIOAuth.appleAuthProvider(),
  FUIOAuth.twitterAuthProvider(),
  FUIOAuth.githubAuthProvider(),
  FUIOAuth.microsoftAuthProvider(),
  FUIOAuth.yahooAuthProvider(),
]
authUI?.providers = providers
```

```objective-c
// Objective-C
@import FirebaseUI;

/* ... */

NSArray<id<FUIAuthProvider>> *providers = @[
  [[FUIEmailAuth alloc] init],
  [[FUIGoogleAuth alloc] init],
  [[FUIFacebookAuth alloc] init],
  [[FUIPhoneAuth alloc] initWithAuthUI:[FUIAuth defaultAuthUI]],
  [FUIOAuth appleAuthProvider],
  [FUIOAuth twitterAuthProvider],
  [FUIOAuth githubAuthProvider],
  [FUIOAuth microsoftAuthProvider],
  [FUIOAuth yahooAuthProvider]
];
self.authUI.providers = providers;
```

For Google Sign-in support, add custom URL schemes to your Xcode project
(step 1 of the [implement Google Sign-In documentation](https://developers.google.com/firebase/docs/auth/ios/google-signin#2_implement_google_sign-in)).

For Sign in with Apple support, add the Sign in with Apple capability to your entitlements file.

For Facebook Login support, follow step 3 and 4 of
[Facebook login documentation](https://developers.google.com/firebase/docs/auth/ios/facebook-login#before_you_begin),
and follow the [Facebook SDK for iOS Getting started documentation](https://developers.facebook.com/docs/ios/getting-started).

Finally, add a call to handle the URL that your application receives at the end
of the Google/Facebook authentication process.

```swift
// Swift
func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
  let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String?
  if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
    return true
  }
  // other URL handling goes here.
  return false
}
```

```objective-c
// Objective-C
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary *)options {
  NSString *sourceApplication = options[UIApplicationOpenURLOptionsSourceApplicationKey];
  return [[FUIAuth defaultAuthUI] handleOpenURL:url sourceApplication:sourceApplication];
}
```

### Sign In

To start the authentication flow, obtain an `authViewController` instance from
`FUIAuth`.  In order to leverage FirebaseUI for iOS you must display the
`authViewController`; you can present it as the first view controller of your
app or present it from another view controller within your app.  In order to
present the `authViewController` obtain as instance as follows:

```swift
// Swift

// Present the auth view controller and then implement the sign in callback.
let authViewController = authUI!.authViewController()

func authUI(_ authUI: FUIAuth, didSignInWithAuthDataResult authDataResult: AuthDataResult?, error: Error?) {
  // handle user (`authDataResult.user`) and error as necessary
}
```

```objective-c
// Objective-C
UINavigationController *authViewController = [authUI authViewController];
// Use authViewController as your root view controller,
// or present it on top of an existing view controller.

- (void)authUI:(FUIAuth *)authUI
    didSignInWithAuthDataResult:(nullable FIRAuthDataResult *)authDataResult
         error:(nullable NSError *)error {
  // Implement this method to handle signed in user (`authDataResult.user`) or error if any.
}
```

### Configuring Email Link Sign In
To use email link sign in, you will first need to enable it in the Firebase Console. Additionally, you will also have to enable Firebase Dynamic Links.

You can enable email link sign in by initializing an `FUIEmailAuth` instance with `FIREmailLinkAuthSignInMethod`. You will also need to provide a valid `FIRActionCodeSettings` object with `handleCodeInApp` set to true. Additionally, you need to whitelist the URL you pass to the iniatializer; you can do so in the Firebase Console (Authentication -> Sign in Methods -> Authorized domains).

```objective-c
// Objective-C
FIRActionCodeSettings *actionCodeSettings = [[FIRActionCodeSettings alloc] init];
actionCodeSettings.URL = [NSURL URLWithString:@"https://example.appspot.com"];
actionCodeSettings.handleCodeInApp = YES;
[actionCodeSettings setAndroidPackageName:@"com.firebase.example"
                    installIfNotAvailable:NO
                           minimumVersion:@"12"];
```

```swift
// Swift
var actionCodeSettings = ActionCodeSettings()
actionCodeSettings.url = URL(string: "https://example.appspot.com")
actionCodeSettings.handleCodeInApp = true
actionCodeSettings.setAndroidPackageName("com.firebase.example", installIfNotAvailable: false, minimumVersion: "12")
```

Once you catch the deep link, you will need to pass it to the auth UI so it can be handled.

```objective-c
// Objective-C
[FUIAuth.defaultAuthUI handleOpenURL:url sourceApplication:sourceApplication];
```

```swift
// Swift
Auth.defaultAuthUI.handleOpenURL(url, sourceApplication: sourceApplication)
```
We support cross device email link sign in for the normal flows. It is not supported with anonymous user upgrade. By default, cross device support is enabled. You can disable it setting `forceSameDevice` to false in the `FUIEmailAuth` initializer.

## Customizing FirebaseUI for authentication
### Custom Terms of Service (ToS) and privacy policy URLs

The Terms of Service URL for your application, which is displayed on the
email/password account creation screen, can be specified as follows:

```swift
// Swift
let kFirebaseTermsOfService = URL(string: "https://firebase.google.com/terms/")!
authUI?.tosurl = kFirebaseTermsOfService
```

```objective-c
// Objective-C
authUI.TOSURL = [NSURL URLWithString:@"https://example.com/tos"];
```

The same applies to the URL of your privacy policy:
```swift
// Swift
let kFirebasePrivacyPolicy = URL(string: "https://policies.google.com/privacy")!
authUI?.privacyPolicyURL = kFirebasePrivacyPolicy
```

### Custom strings

You can override the default messages and prompts shown to your users. This can
be useful for things such as adding support for languages other than English.

In order to do so:

```swift
// Swift
authUI?.customStringsBundle = NSBundle.mainBundle() // Or any custom bundle.
```

```objective-c
// Objective-C
authUI.customStringsBundle = [NSBundle mainBundle]; // Or any custom bundle.
```

The bundle should include [.strings](https://github.com/firebase/FirebaseUI-iOS/blob/master/FirebaseAuthUI/Strings/en.lproj/FirebaseAuthUI.strings)
files that have the same names as the default files, namely `FirebaseAuthUI`,
`FirebaseGoogleAuthUI`, and `FirebaseFacebookAuthUI`. Each string in these files
should have the same key as its counterpart in the default `.strings` files.

### Custom sign-in screen

You can customize everything about the authentication method picker screen,
except for the actual sign-in buttons and their position.

In order to do so, create a subclass of `FUIAuthPickerViewController`  and
customize it to your needs. Provide `FUIAuth` with an instance of your
subclass by implementing the delegate method
`authPickerViewControllerForAuthUI:` as follows:

```swift
// Swift
func authPickerViewController(for authUI: FUIAuth) -> FUIAuthPickerViewController {
  return CustomAuthPickerViewController(authUI: authUI)
}
```

```objective-c
// Objective-C
- (FUIAuthPickerViewController *)authPickerViewControllerForAuthUI:(FUIAuth *)authUI {
  return [[CustomAuthPickerViewController alloc] initWithAuthUI:authUI];
}
```

### Custom email/password screens

You can customize all email/password screens, including but not limited to:
- Hiding the top `UINavigationBar`
- Adding a `Cancel` button
- Use a UI view other than `UITableView`

Things that are not customizable:
- `UIAlertController` popups (showing error labels instead)
- Modifying the screen flow (combining screens or skipping particular screens)
- Disabling validation, including email validation

To customize the email/password screens, create a subclass of appropriate
controller and implement it to your needs. Then set up `FUIAuth` with an
instance of your subclass by implementing the following delegate methods:
```swift
// Swift
func emailEntryViewController(for authUI: FUIAuth) -> FUIEmailEntryViewController {
  return CustomEmailEntryViewController(authUI: authUI)
}

func passwordSignInViewController(for authUI: FUIAuth, email: String) -> FUIPasswordSignInViewController {
  return CustomPasswordSignInViewController(authUI: authUI, email: email)
}

func passwordSignUpViewController(for authUI: FUIAuth, email: String) -> FUIPasswordSignUpViewController {
  return CustomPasswordSignUpViewController(authUI: authUI, email: email)
}

func passwordRecoveryViewController(for authUI: FUIAuth, email: String) -> FUIPasswordRecoveryViewController {
  return CustomPasswordRecoveryViewController(authUI: authUI, email: email)
}

func passwordVerificationViewController(for authUI: FUIAuth, email: String, newCredential: AuthCredential) -> FUIPasswordVerificationViewController {
  return CustomPasswordVerificationViewController(authUI: authUI, email: email, newCredential: newCredential)
}
```

```objective-c
// Objective-C
- (FUIEmailEntryViewController *)emailEntryViewControllerForAuthUI:(FUIAuth *)authUI {
  return [[CustomEmailEntryViewController alloc] initWithAuthUI:authUI];

}

- (FUIPasswordSignInViewController *)passwordSignInViewControllerForAuthUI:(FUIAuth *)authUI
                                                                     email:(NSString *)email {
  return [[CustomPasswordSignInViewController alloc] initWithAuthUI:authUI
                                                              email:email];

}

- (FUIPasswordSignUpViewController *)passwordSignUpViewControllerForAuthUI:(FUIAuth *)authUI
                                                                     email:(NSString *)email {
  return [[CustomPasswordSignUpViewController alloc] initWithAuthUI:authUI
                                                              email:email];

}

- (FUIPasswordRecoveryViewController *)passwordRecoveryViewControllerForAuthUI:(FUIAuth *)authUI
                                                                         email:(NSString *)email {
  return [[CustomPasswordRecoveryViewController alloc] initWithAuthUI:authUI
                                                                email:email];

}

- (FUIPasswordVerificationViewController *)passwordVerificationViewControllerForAuthUI:(FUIAuth *)authUI
                                                                             email:(NSString *)email
                                                                     newCredential:(FIRAuthCredential *)newCredential {
  return [[CustomPasswordVerificationViewController alloc] initWithAuthUI:authUI
                                                                    email:email
                                                            newCredential:newCredential];
}
```

In your custom view controllers, call the same FirebaseUI methods as their
parent classes. For example:
- `- (void)onNext:(NSString *)textFieldValue; // Or any action that leads to the next screen`
- `- (void)didChangeTextField:(NSString *)textFieldValue; // Usually called in viewWillAppear and after modification of text entry field`
- `- (void)onBack;`
- `- (void)cancelAuthorization;`

Refer to the Objective-C and Swift samples for examples of how you can customize
these views.

## Handling auto-upgrade of anonymous users
By default, the auto-upgrade of anonymous users is disabled. You can enable it 
by simply changing the associated attribute of your Firebase Auth instance:
```swift
authUI?.shouldAutoUpgradeAnonymousUsers = true
```

Enabling auto-upgrade of anonymous users increases the complexity of your auth
flow by adding several more edge cases that need to be handled. As opposed to
normal auth, which only involves one step, auto-upgrade presents three steps
with four possibilities total:
- At app launch, anonymously authenticate the user. User state can be
  accumulated on the anonymous user and linked to the non-anonymous account
  later.
- At some point in your app, present the auth flow and authenticate the user
  using a non-anonymous auth method.
- Following a successful auth attempt, if the user signs in to a new account,
  the anonymous account and the new account can be linked together without
  issue.
- Otherwise, if logging into an existing user, FirebaseUI will return a merge
  conflict error containing the resulting `FIRAuthDataResult` corresponding to
  the existing account. This value should be used to login to the existing
  account without linking to the anonymous user, as the two accounts may have
  conflicting state (the anonymous account state will be discarded).

```swift
func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
  if let error = error as NSError?,
      error.code == FUIAuthErrorCode.mergeConflict.rawValue {
    // Merge conflict error, discard the anonymous user and login as the existing
    // non-anonymous user.
    guard let credential = error.userInfo[FUIAuthCredentialKey] as? AuthCredential else {
      print("Received merge conflict error without auth credential!")
      return
    }

    Auth.auth().signInAndRetrieveData(with: credential) { (dataResult, error) in
      if let error = error as NSError? {
        print("Failed to re-login: \(error)")
        return
      }

      // Handle successful login
    }
  } else if let error = error {
    // Some non-merge conflict error happened.
    print("Failed to log in: \(error)")
    return
  }

  // Handle successful login
}
```
