# FirebaseUI for iOS — UI Bindings for Firebase [![Build Status](https://travis-ci.org/firebase/FirebaseUI-iOS.svg?branch=master)](https://travis-ci.org/firebase/FirebaseUI-iOS)

FirebaseUI is an open-source library for iOS that allows you to quickly connect common UI elements to the [Firebase](https://firebase.google.com?utm_source=FirebaseUI-iOS) database for data storage, allowing views to be updated in realtime as they change, and providing simple interfaces for common tasks like displaying lists or collections of items.

Additionally, FirebaseUI simplifies Firebase authentication by providing easy to use auth methods that integrate with common identity providers like Facebook, Twitter, and Google as well as allowing developers to use a built in headful UI for ease of development.

FirebaseUI clients are also available for [Android](https://github.com/firebase/FirebaseUI-Android) and [web](https://github.com/firebase/firebaseui-web).

## Installing FirebaseUI for iOS

FirebaseUI supports iOS 8.0+. We recommend using [CocoaPods](http://cocoapods.org/?q=firebaseui-ios), add
the following to your `Podfile`:

```ruby
pod 'FirebaseUI', '~> 0.5'       # Pull in all Firebase UI features
```

If you don't want to use all of FirebaseUI, there are multiple subspecs which can selectively install subsets of the full feature set:

```ruby
# Only pull in the "Database" FirebaseUI features
pod 'FirebaseUI/Database', '~> 0.4'

# Only pull in the "Auth" FirebaseUI features (including Facebook and Google)
pod 'FirebaseUI/Auth', '~> 0.4'

# Only pull in the "Facebook" login features
pod 'FirebaseUI/Facebook', '~> 0.4'

# Only pull in the "Google" login features
pod 'FirebaseUI/Google', '~> 0.4'

```

If you're including FirebaseUI in a Swift project, make sure you also have:

```ruby
platform :ios, '8.0'
use_frameworks!
```

Otherwise, you can download the latest version of the [FirebaseUI.framework from the releases
page](https://github.com/firebase/FirebaseUI-iOS/releases) or include the FirebaseUI
Xcode project from this repo in your project. You also need to [add the Firebase
framework](https://firebase.google.com/docs/ios/setup?utm_campaign=Firebase_update_awareness_general_en_05-18-16_&utm_source=?utm_campaign=Firebase_featureoverview_awareness_analytics_en_05-18-16_&utm_source=?utm_campaign=Firebase_announcement_awareness_general_en_05-18-16_&utm_source=Firebase&utm_medium=ads&utm_medium=?utm_campaign=Firebase_announcement_awareness_general_en_05-18-16_&utm_source=Firebase&utm_medium=ads&utm_medium=?utm_campaign=Firebase_update_awareness_auth_en_05-18-16_&utm_source=?utm_campaign=Firebase_announcement_awareness_general_en_05-18-16_&utm_source=Firebase&utm_medium=ads&utm_medium=?utm_campaign=Firebase_featureoverview_awareness_analytics_en_05-18-16_&utm_source=?utm_campaign=Firebase_announcement_awareness_general_en_05-18-16_&utm_source=Firebase&utm_medium=ads&utm_medium=?utm_campaign=Firebase_announcement_awareness_general_en_05-18-16_&utm_source=Firebase&utm_medium=ads) to your project.

## Local Setup

If you'd like to contribute to FirebaseUI for iOS, you'll need to run the
following commands to get your environment set up:

```bash
$ git clone https://github.com/firebase/FirebaseUI-iOS.git
$ cd FirebaseUI-iOS
$ pod install
```

## Contributing to FirebaseUI

### Contributor License Agreements

We'd love to accept your sample apps and patches! Before we can take them, we
have to jump a couple of legal hurdles.

Please fill out either the individual or corporate Contributor License Agreement
(CLA).

  * If you are an individual writing original source code and you're sure you
    own the intellectual property, then you'll need to sign an [individual CLA]
    (https://developers.google.com/open-source/cla/individual).
  * If you work for a company that wants to allow you to contribute your work,
    then you'll need to sign a [corporate CLA]
    (https://developers.google.com/open-source/cla/corporate).

Follow either of the two links above to access the appropriate CLA and
instructions for how to sign and return it. Once we receive it, we'll be able to
accept your pull requests.

### Contribution Process

1. Submit an issue describing your proposed change to the repo in question.
2. The repo owner will respond to your issue promptly.
3. If your proposed change is accepted, and you haven't already done so, sign a
   Contributor License Agreement (see details above).
4. Fork the desired repo, develop and test your code changes.
5. Ensure that your code adheres to the existing style of the library to which
   you are contributing.
6. Ensure that your code has an appropriate set of unit tests which all pass.
7. Submit a pull request
