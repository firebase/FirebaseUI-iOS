# FirebaseUI for iOS — Phone Auth

You can use Firebase Phone Authentication to sign in a user by sending an SMS message to the user's phone.The user signs in using a one-time code contained in the SMS message.

## Table of Contents

1. [Installation](#installation)
1. [Integration](#using-firebasephoneui-for-authentication)
1. [Customization](#customizing)

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