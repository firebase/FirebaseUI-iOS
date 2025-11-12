FirebaseUI Demo in Objective-C
===================================

This is a simple FirebaseUI demo in Objective-C showcasing Database and Storage features. It demonstrates:
  1. The ease of integrating with FirebaseUI
  1. Using a `UITableView` outside of a `UITableViewController`
  1. Using custom XIBs in FirebaseUI to achieve a custom look and feel
  1. Using a model object to get strongly typed objects from Firebase
  1. Using a custom `FUITableViewDataSource` to add deletion

## Installation

``` bash
git clone https://github.com/firebase/FirebaseUI-iOS.git
cd FirebaseUI-iOS/samples/objc
pod install
open FirebaseUI-demo-objc.xcworkspace
```

## Project Configuration

1. Download `GoogleService-Info.plist` from [Firebase Console](https://console.firebase.google.com)
2. Copy it to `samples/objc/` directory
3. Configure your Firebase Database and Storage in the Firebase Console

## Samples

### Chat Sample

This sample demonstrates real-time database functionality using `FUITableViewDataSource` to bind a Firebase query to a `UITableView`. The chat messages are stored in the Firebase Realtime Database and updated in real-time.

Note: This sample uses [anonymous authentication](https://firebase.google.com/docs/auth/ios/anonymous-auth), so make sure anonymous auth is enabled in Firebase Console.

### Storage Sample

This sample demonstrates Firebase Storage integration, showing how to upload and display images stored in Firebase Storage.

Note: Make sure to set up the [Storage Security Rules](https://firebase.google.com/docs/storage/security/start#sample-rules) for your bucket.