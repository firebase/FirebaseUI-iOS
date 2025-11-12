FirebaseUI Demo in Swift
=============================

This directory contains Swift code samples demonstrating FirebaseUI Database and Storage features.

## Installation

``` bash
git clone https://github.com/firebase/FirebaseUI-iOS.git
cd FirebaseUI-iOS/samples/swift
pod install
open FirebaseUI-demo-swift.xcworkspace
```

## Project Configuration

1. Download `GoogleService-Info.plist` from [Firebase Console](https://console.firebase.google.com)
2. Copy it to `samples/swift/` directory
3. Configure your Firebase Database and Storage in the Firebase Console

## Samples

### Chat Sample

This sample demonstrates real-time database functionality using `FUICollectionViewDataSource` to bind a Firebase query to a `UICollectionView`. The chat messages are stored in the Firebase Realtime Database and updated in real-time.

Note: This sample uses [anonymous authentication](https://firebase.google.com/docs/auth/ios/anonymous-auth), so make sure anonymous auth is enabled in Firebase Console.

### Storage Sample

This sample demonstrates Firebase Storage integration, showing how to upload and display images stored in Firebase Storage.

Note: Make sure to set up the [Storage Security Rules](https://firebase.google.com/docs/storage/security/start#sample-rules) for your bucket.
