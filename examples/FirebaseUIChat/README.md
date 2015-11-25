FirebaseUI Chat Demo
====================

This is a super simple FirebaseUI Chat demo. It shows:
  1. The ease of integrating with FirebaseUI
  1. Using a `UITableView` outside of a `UITableViewController`
  1. Using custom XIBs in FirebaseUI to achieve a custom look and feel
  1. Using a model object to get strongly typed objects from Firebase
  1. Using a custom `FirebaseTableViewDataSource` to add deletion
  1. Using `FirebaseLoginViewController` to add authentication

In order to install and run:
``` bash
git clone https://github.com/firebase/FirebaseUI-iOS.git
cd FirebaseUI-iOS/examples/FirebaseUIChat
pod install
open FirebaseUIChat.xcworkspace
```
Once you've opened the workspace, go into `Supporting Files/Info.plist` and either fill in the social provider information currently commented out, or delete extra providers you're not interested in. For providers you choose to keep, enable them in your Firebase Dashboard according to the [user authentication docs](https://www.firebase.com/docs/ios/guide/user-auth.html). In `ViewController.m` make sure to only enable providers that you've configured properly.

