# FirebaseUI for iOS — UI Bindings for Firebase

![Database](https://github.com/firebase/FirebaseUI-iOS/actions/workflows/database.yml/badge.svg) ![Firestore](https://github.com/firebase/FirebaseUI-iOS/actions/workflows/firestore.yml/badge.svg) ![Storage](https://github.com/firebase/FirebaseUI-iOS/actions/workflows/storage.yml/badge.svg) ![SwiftUI Auth](https://github.com/firebase/FirebaseUI-iOS/actions/workflows/swiftui-auth.yml/badge.svg) ![Samples](https://github.com/firebase/FirebaseUI-iOS/actions/workflows/sample.yml/badge.svg)

FirebaseUI is an open-source library for iOS that allows you to quickly connect common UI elements to the [Firebase](https://firebase.google.com?utm_source=FirebaseUI-iOS) database for data storage, allowing views to be updated in realtime as they change, and providing simple interfaces for common tasks like displaying lists or collections of items.

Additionally, FirebaseUI provides modern SwiftUI authentication components that simplify Firebase authentication by integrating with common identity providers like Facebook, Twitter, Google, and Apple.

FirebaseUI clients are also available for [Android](https://github.com/firebase/FirebaseUI-Android) and [web](https://github.com/firebase/firebaseui-web).

![](https://raw.githubusercontent.com/firebase/FirebaseUI-iOS/main/samples/demo.gif)

## Installing FirebaseUI for iOS

FirebaseUI supports iOS 17.0+ and Xcode 15+. 

### Swift Package Manager (Recommended)

For SwiftUI authentication and modern features, use Swift Package Manager:

1. In Xcode, go to File > Add Package Dependencies
2. Enter the repository URL: `https://github.com/firebase/FirebaseUI-iOS`
3. Select the modules you need:
   - `FirebaseAuthSwiftUI` - Core SwiftUI authentication
   - `FirebaseGoogleSwiftUI` - Google Sign-In
   - `FirebaseFacebookSwiftUI` - Facebook Login
   - `FirebasePhoneAuthSwiftUI` - Phone Authentication
   - `FirebaseAppleSwiftUI` - Sign in with Apple
   - `FirebaseTwitterSwiftUI` - Twitter Login
   - `FirebaseOAuthSwiftUI` - Generic OAuth providers

### CocoaPods

For UIKit data binding features (Database, Firestore, Storage), use [CocoaPods](https://cocoapods.org/pods/FirebaseUI):

```ruby
# Only pull in Firestore features
pod 'FirebaseUI/Firestore'

# Only pull in Database features
pod 'FirebaseUI/Database'

# Only pull in Storage features
pod 'FirebaseUI/Storage'
```

If you're including FirebaseUI in a project, make sure you also have:

```ruby
platform :ios, '13.0'
use_frameworks!
```

## Documentation

The READMEs for components of FirebaseUI can be found in their respective project folders.

### SwiftUI Components
- [SwiftUI Authentication](FirebaseSwiftUI/README.md)

### UIKit Data Binding Components
- [Database](FirebaseDatabaseUI/README.md)
- [Firestore](FirebaseFirestoreUI/README.md)
- [Storage](FirebaseStorageUI/README.md)

## Local Setup

If you'd like to contribute to FirebaseUI for iOS, you'll need to run the following commands to get your environment set up:

```bash
$ git clone https://github.com/firebase/FirebaseUI-iOS.git
$ cd FirebaseUI-iOS

# For SwiftUI components (uses Swift Package Manager)
$ cd samples/swiftui/FirebaseSwiftUISample
$ open FirebaseSwiftUISample.xcodeproj

# For UIKit data binding components (uses CocoaPods)
$ cd FirebaseDatabaseUI # or FirebaseFirestoreUI, FirebaseStorageUI
$ pod install
```

## Sample Project Configuration

You'll have to configure your Xcode project in order to run the SwiftUI samples.

1. Your Xcode project should contain a `GoogleService-Info.plist`, downloaded from [Firebase console](https://console.firebase.google.com) when you add your app to a Firebase project.<br>
Copy the `GoogleService-Info.plist` into the sample project folder.

1. Update URL Types (for OAuth providers).<br>
Go to `Project Settings -> Info tab -> Url Types` and update values for:
	+ `REVERSED_CLIENT_ID` (get value from `GoogleService-Info.plist`) - Required for Google Sign-In
	+ `fb{your-app-id}` (put Facebook App Id) - Required for Facebook Login

1. For Facebook Login, update `Info.plist` with Facebook configuration values:
	+ `FacebookAppID -> {your-app-id}` (put Facebook App Id)
	+ Enable Keychain Sharing: `Project Settings -> Capabilities -> KeyChain Sharing -> ON`

1. Don't forget to configure your Firebase project using [Firebase console](https://console.firebase.google.com).

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
1. The repo owner will respond to your issue promptly.
1. If your proposed change is accepted, and you haven't already done so, sign a
   Contributor License Agreement (see details above).
1. Fork the desired repo, develop and test your code changes.
1. Ensure that your code adheres to the existing style of the library to which
   you are contributing.
1. Ensure that your code has an appropriate set of unit tests which all pass.
1. Submit a pull request
