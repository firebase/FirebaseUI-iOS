FirebaseUI Chat Demo in Objective C
===================================

This is a super simple FirebaseUI Chat demo in Objective C. It shows:
  1. The ease of integrating with FirebaseUI
  1. Using a `UITableView` outside of a `UITableViewController`
  1. Using custom XIBs in FirebaseUI to achieve a custom look and feel
  1. Using a model object to get strongly typed objects from Firebase
  1. Using a custom `FUITableViewDataSource` to add deletion
  1. Using `FirebaseLoginViewController` to add authentication

In order to install and run:
``` bash
git clone https://github.com/firebase/FirebaseUI-iOS.git
cd FirebaseUI-iOS/samples/objc
pod install
open FirebaseUI-demo-objc.xcworkspace
```
Once you've opened the workspace, go into `Supporting Files/Info.plist` and either fill in the social provider information currently commented out, or delete extra providers you're not interested in. For providers you choose to keep, enable them in your Firebase Dashboard according to the [user authentication docs](https://www.firebase.com/docs/ios/guide/user-auth.html). In `ViewController.m` make sure to only enable providers that you've configured properly.

### Project configuration

Please follow steps described [here](https://github.com/firebase/FirebaseUI-iOS#mandatory-sample-project-configuration) in order to run the sample project.

### Chat Sample

This sample uses [anonymous authentication](https://firebase.google.com/docs/auth/ios/anonymous-auth),
so make sure anonymous auth is enabled in Firebase console.

### Auth Sample

This sample uses [email/password](https://firebase.google.com/docs/auth/ios/password-auth),
[Google](https://firebase.google.com/docs/auth/ios/google-signin),
[Facebook](https://firebase.google.com/docs/auth/ios/facebook-login),
[Twitter](https://firebase.google.com/docs/auth/ios/twitter-login)
and [Phone](https://firebase.google.com/docs/auth/ios/phone-auth)
auth so make sure those are enabled in Firebase console.

The auth example requires a little more setup (adding url schemes, etc)
since it depends on the various keys and tokens for the different auth
services your app will support. Take a look at the [Auth README](../../FirebaseAuthUI/README.md)
for more information.

### Storage Sample

This sample does not use a logged-in user, so make to set up the [Storage Security Rules](https://firebase.google.com/docs/storage/security/start#sample-rules)
for your bucket to allow that.