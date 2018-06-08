# FirebaseUI for iOS — Phone Auth

You can use Firebase Phone Authentication to sign in a user by sending an SMS message to the user's phone.The user signs in using a one-time code contained in the SMS message.

## Table of Contents

1. [Installation](#installation)
1. [Integration](#using-firebasephoneui-for-authentication)
1. [Customization](#customizing)
1. [Integration cheat sheet](#integration-cheat-sheet)

## Installation
### Importing FirebaseUI Phone Auth components
Add the following to your `Podfile`:
```ruby
 pod 'FirebaseUI/Auth'
 pod 'FirebaseUI/Phone'
```

### Configuring sign-in provider
To use FirebaseUI to authenticate users you first need to configure each provider you want to use in
their own developer app settings. Please read the *Before you begin* section of the [Firebase
Phone Auth configuration guides](https://firebase.google.com/docs/auth/ios/phone-auth#before_you_begin).

## Using FirebasePhoneUI for Authentication

### Integration

In order to use Phone Auth you should initialize Phone provider and add it to the list of FUIAuth providers. Please notice that you should use only one instance of Phone Auth providers. It can be retrieved form FUIAuth providers list.

```swift
// Swift
import Firebase
import FirebaseAuthUI
import FirebasePhoneAuthUI

/* ... */

FUIAuth.defaultAuthUI()?.delegate = self
let phoneProvider = FUIPhoneAuth.init(authUI: FUIAuth.defaultAuthUI()!)
FUIAuth.defaultAuthUI()?.providers = [phoneProvider]
```

```objective-c
// Objective-C
@import FirebaseAuthUI;      // OR #import <FirebaseAuthUI/FirebaseAuthUI.h>
@import FirebasePhoneAuthUI; // OR #import <FirebasePhoneAuthUI/FUIPhoneAuth.h>

/* ... */

[FUIAuth defaultAuthUI].delegate = self; // delegate should be retained by you!
FUIPhoneAuth *phoneProvider = [[FUIPhoneAuth alloc] initWithAuthUI:[FUIAuth defaultAuthUI]];
[FUIAuth defaultAuthUI].providers = @[phoneProvider];
```

### Sign In

To start the authentication flow: 

```swift
// Swift
let phoneProvider = FUIAuth.defaultAuthUI()?.providers.first as! FUIPhoneAuth
phoneProvider.signIn(withPresenting: currentlyVisibleController, phoneNumber: nil)
```

```objective-c
// Objective-C
FUIPhoneAuth *phoneProvider = [FUIAuth defaultAuthUI].providers.firstObject;
[phoneProvider signInWithPresentingViewController:currentlyVisibleController phoneNumber:nil];
```

## Customizing
Customizing of Phone Auth is planned to be implemented in 2017 Q4

## Integration cheat sheet
Here you can find steps things that need to be checked in case of any issues with Firebase Phone Auth integration problems.

In case  need to handle push notifications yourself:

1. Add `APNS Key` or `APNS cert` to Firebase console project.
<br>If `APNS cert` is used than check that you uploaded certificate with the same `bundleID` as Firebase iOS app `bundleID`.
1. In the Xcode `Project settings` -> `Capabilities` enable `Push Notifications`
1. In the project `Info.plist` set to `NO` value of `FirebaseAppDelegateProxyEnabled` (add this key if needed)
1. In the `AppDelegate` `didRegisterForRemoteNotificationsWithDeviceToken` call `[FUIAuth.defaultAuthUI.auth setAPNSToken:deviceToken]`
<br>In this case The type of the token (production or sandbox) will be attempted to be automatically detected. There is other method to set it manually.
1. In the `AppDelegate` `application:didReceiveRemoteNotification:fetchCompletionHandler:` call `[FUIAuth.defaultAuthUI.auth canHandleNotification:userInfo]`
1. In the `AppDelegate` `application:didFinishLaunchingWithOptions:` call `[FIRApp configure]`
1. In the `AppDelegate` `application:openURL:options:` return `[FUIAuth.defaultAuthUI handleOpenURL:url sourceApplication:sourceApplication]` 
1. Add `REVERSED_CLIENT_ID` as URL scheme to `Project settings`
1. Add `GoogleService-Info.plist` to your project
1. In you controller call:
```objective-c
  [FUIAuth defaultAuthUI].delegate = self; // delegate should be retained by you!
  FUIPhoneAuth *phoneProvider = [[FUIPhoneAuth alloc] initWithAuthUI:[FUIAuth defaultAuthUI]];
  [FUIAuth defaultAuthUI].providers = \@[phoneProvider];
```
11\. To start Phone Auth, please call:
```objective-c
  FUIPhoneAuth *phoneProvider = [FUIAuth defaultAuthUI].providers.firstObject;
  [phoneProvider signInWithPresentingViewController:self phoneNumber:nil];
```
You can skip all errors, FirbaseUI Phone Auth will display all error messages for you.
<br>You may need only to handle error code `FUIAuthErrorCodeUserCancelledSignIn`.

If you don't need to handle APNS yourself, than don't do steps 3, 4, 5.

Please notice that you can use either APNS key OR APNS certificate.
<br>One APNS Key can be used for all your iOS app from the same Apple Developer account.