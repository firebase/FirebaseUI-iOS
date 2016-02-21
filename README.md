# FirebaseUI for iOS — UI Bindings for Firebase

FirebaseUI is an open-source library for iOS that allows you to quickly connect common UI elements to the [Firebase](https://www.firebase.com/?utm_source=firebaseui-ios) database for data storage, allowing views to be updated in realtime as they change, and providing simple interfaces for common tasks like displaying lists or collections of items.

Additionally, FirebaseUI simplifies Firebase authentication by providing easy to use auth methods that integrate with common identity providers like Facebook, Twitter, and Google as well as allowing developers to use a built in headful UI for ease of development.

A compatible FirebaseUI client is also available for [Android](https://github.com/firebase/FirebaseUI-Android).

## Installing FirebaseUI for iOS

FirebaseUI supports iOS 8.0+. We recommend using [CocoaPods](http://cocoapods.org/?q=firebaseui-ios), add
the following to your `Podfile`:

```
pod 'FirebaseUI', '~> 0.3'       # Pull in all Firebase UI features
```

If you don't want to use all of FirebaseUI, there are multiple subspecs which can selectively install subsets of the full feature set:

```
# Only pull in the "Core" FirebaseUI features
pod 'FirebaseUI/Core', '~> 0.3'

# Pull in the "Auth" FirebaseUI features: Facebook, Google, Twitter, and Email/Password auth
pod 'FirebaseUI/Auth', '~> 0.3'

# Selectively pull in Auth providers
pod 'FirebaseUI/Facebook', '~> 0.3.2'
pod 'FirebaseUI/Google', '~> 0.3.2'
pod 'FirebaseUI/Twitter', '~> 0.3.2'
pod 'FirebaseUI/Password', '~> 0.3.2'
```

If you're including FirebaseUI in a Swift project, make sure you also have:

```
platform :ios, '8.0'
use_frameworks!
```

Otherwise, you can download the latest version of the [FirebaseUI.framework from the releases
page](https://github.com/firebase/FirebaseUI-iOS/releases) or include the FirebaseUI
Xcode project from this repo in your project. You also need to [add the Firebase
framework](https://www.firebase.com/docs/ios-quickstart.html?utm_source=firebaseui-ios) to your project.

## Getting Started with Firebase

FirebaseUI requires Firebase in order to store location data. You can [sign up here for a free
account](https://www.firebase.com/signup/?utm_source=firebaseui-ios).

## FirebaseUI for iOS Quickstart

This is a quickstart on how to use FirebaseUI's core features to speed up iOS development with Firebase. FirebaseUI includes the following features:

### FirebaseUI Core
Provides core data binding capabilities as well as specific datasources for lists of data. Skip to the [Core API overview](https://github.com/firebase/firebaseui-ios#firebaseui-core-api) for more information.

Class  | Description
------------- | -------------
FirebaseTableViewDataSource | Data source to bind a Firebase query to a UITableView
FirebaseCollectionViewDataSource | Data source to bind a Firebase query to a UICollectionView
FirebaseArray | Keeps an array synchronized to a Firebase query
FirebaseDataSource | Generic superclass to create a custom data source

### FirebaseUI Auth
Provides authentication providers as well as concrete implementations for Facebook, Google, Twitter, and Firbase email/password, plus a headful UI that handles auth state and error conditions. Skip to the [Auth API overview](https://github.com/firebase/firebaseui-ios#firebaseui-auth-api) for more information.

Class  | Description
------------- | -------------
FirebaseAuthProvider | Generic superclass for authentication providers
FirebaseFacebookAuthProvider | Allows for one method login to Facebook
FirebaseGoogleAuthProvider | Allows for one method login to Google
FirebaseTwitterAuthProvider | Allows for one method login to Twitter
FirebasePasswordAuthProvider | Allows for one method login to Firebases email/password authentication
FirebaseLoginViewController | Flexible headful UI which handles login, logout, and error conditions from all identity providers

For a more in-depth explanation of each of the above, check the usage instructions below or read the [docs](https://firebaseui.firebaseapp.com/docs/ios/index.html).

## FirebaseUI Core API
### FirebaseTableViewDataSource

`FirebaseTableViewDataSource` implements the `UITableViewDataSource` protocol to automatically use Firebase as a data source for your `UITableView`.

#### Objective-C
```objective-c
YourViewController.h
...
@property (strong, nonatomic) Firebase *firebaseRef;
@property (strong, nonatomic) FirebaseTableViewDataSource *dataSource;
```

```objective-c
YourViewController.m
...
self.firebaseRef = [[Firebase alloc] initWithUrl:@"https://<YOUR-FIREBASE-APP>.firebaseio.com/"];
self.dataSource = [[FirebaseTableViewDataSource alloc] initWithRef:firebaseRef cellReuseIdentifier:@"<YOUR-REUSE-IDENTIFIER>" view:self.tableView];

[self.dataSource populateCellWithBlock:^(UITableViewCell *cell, FDataSnapshot *snap) {
  // Populate cell as you see fit, like as below
  cell.textLabel.text = snap.key;
}];

[self.tableView setDataSource:self.dataSource];
```

#### Swift
```swift
YourViewController.swift
...
let firebaseRef = Firebase(url:"https://<YOUR-FIREBASE-APP>.firebaseio.com/")
let dataSource: FirebaseTableViewDataSource!
...
self.dataSource = FirebaseTableViewDataSource(ref: self.firebaseRef, cellReuseIdentifier: "<YOUR-REUSE-IDENTIFIER>", view: self.tableView)

self.dataSource.populateCellWithBlock { (cell: UITableViewCell, obj: NSObject) -> Void in
  let snap = obj as! FDataSnapshot

  // Populate cell as you see fit, like as below
  cell.textLabel?.text = snap.key as String
}

self.tableView.dataSource = self.dataSource

```

### FirebaseCollectionViewDataSource

`FirebaseCollectionViewDataSource` implements the `UICollectionViewDataSource` protocol to automatically use Firebase as a data source for your `UICollectionView`.

#### Objective-C
```objective-c
YourViewController.h
...
@property (strong, nonatomic) Firebase *firebaseRef;
@property (strong, nonatomic) FirebaseCollectionViewDataSource *dataSource;
```

```objective-c
YourViewController.m
...
self.firebaseRef = [[Firebase alloc] initWithUrl:@"https://<YOUR-FIREBASE-APP>.firebaseio.com/"];
self.dataSource = [[FirebaseTableViewDataSource alloc] initWithRef:firebaseRef cellReuseIdentifier:@"<YOUR-REUSE-IDENTIFIER>" view:self.CollectionView];

[self.dataSource populateCellWithBlock:^(UICollectionViewCell *cell, FDataSnapshot *snap) {
  // Populate cell as you see fit, like as below
  cell.backgroundColor = [UIColor blueColor];
}];

[self.collectionView setDataSource:self.dataSource];
```

#### Swift
```swift
YourViewController.swift
...
let firebaseRef = Firebase(url: "https://<YOUR-FIREBASE-APP>.firebaseio.com/")
let dataSource: FirebaseCollectionViewDataSource!
...
self.dataSource = FirebaseCollectionViewDataSource(ref: self.firebaseRef, cellReuseIdentifier: "<YOUR-REUSE-IDENTIFIER>", view: self.collectionView)

self.dataSource.populateCellWithBlock { (cell: UICollectionViewCell, obj: NSObject) -> Void in
  let snap = obj as! FDataSnapshot

  // Populate cell as you see fit, like as below
  cell.backgroundColor = UIColor.blueColor()
}

self.collectionView.dataSource = self.dataSource

```

## Customizing your UITableView or UICollectionView

You can use `FirebaseTableViewDataSource` or `FirebaseCollectionViewDataSource` in several ways to create custom UITableViews or UICollectionViews. For more information on how to create custom UITableViews, check out the following tutorial on [TutsPlus](http://code.tutsplus.com/tutorials/ios-sdk-crafting-custom-uitableview-cells--mobile-15702). For more information on how to create custom UICollectionViews, particularly how to implement a UICollectionViewLayout, check out the following tutorial on Ray Wenderlich in [Objective-C](http://www.raywenderlich.com/22324/beginning-uicollectionview-in-ios-6-part-12) and [Swift](http://www.raywenderlich.com/78550/beginning-ios-collection-views-swift-part-1).

### Using the Default UI*ViewCell Implementation

You can use the default `UITableViewCell` or `UICollectionViewCell` implementations to get up and running quickly. For `UITableViewCell`s, this allows for the `cell.textLabel` and the `cell.detailTextLabel` to be used directly out of the box. For `UICollectionViewCell`s, you will have to add subviews to the contentView in order for it to be useful.

#### Objective-C UITableView and UICollectionView with Default UI*ViewCell
```objective-c
self.dataSource = [[FirebaseTableViewDataSource alloc] initWithRef:firebaseRef cellReuseIdentifier:@"<YOUR-REUSE-IDENTIFIER>" view:self.tableView];

[self.dataSource populateCellWithBlock:^(UITableViewCell *cell, FDataSnapshot *snap) {
  // Populate cell as you see fit, like as below
  cell.textLabel.text = snap.key;
}];

[self.tableView setDataSource:self.dataSource];
```

```objective-c
self.dataSource = [[FirebaseCollectioneViewDataSource alloc] initWithRef:firebaseRef cellReuseIdentifier:@"<YOUR-REUSE-IDENTIFIER>" view:self.CollectionView];

[self.dataSource populateCellWithBlock:^(UICollectionViewCell *cell, FDataSnapshot *snap) {
  // Populate cell as you see fit by adding subviews as appropriate
  [cell.contentView addSubview:customView];
}];

[self.collectionView setDataSource:self.dataSource];
```

#### Swift UITableView and UICollectionView with Default UI*ViewCell
```swift
self.dataSource = FirebaseTableViewDataSource(ref: firebaseRef cellReuseIdentifier: @"<YOUR-REUSE-IDENTIFIER>" view: self.tableView)

self.dataSource.populateCellWithBlock { (cell: UITableViewCell, obj: NSObject) -> Void in
  // Populate cell as you see fit, like as below
  cell.textLabel.text = snap.key;
}

self.tableView.dataSource = self.dataSource;
```

```swift
self.dataSource = FirebaseCollectionViewDataSource(ref: firebaseRef cellReuseIdentifier: @"<YOUR-REUSE-IDENTIFIER>" view: self.collectionView)

self.dataSource.populateCellWithBlock { (cell: UICollectionViewCell, obj: NSObject) -> Void in
  // Populate cell as you see fit by adding subviews as appropriate
  cell.contentView.addSubview(customView)
}

self.collectionView.dataSource = self.dataSource;
```

### Using Storyboards and Prototype Cells

Create a storyboard that has either a `UITableViewController`, `UICollectionViewController` or a `UIViewController` with a `UITableView` or `UICollectionView`. Drag a prototype cell onto the `UITableView` or `UICollectionView` and give it a custom reuse identifier which matches the reuse identifier being used when instantiating the `Firebase*ViewDataSource`. When using prototype cells, make sure to use `prototypeReuseIdentifier` instead of `cellReuseIdentifier`.

Drag and other properties onto the cell and associate them with properties of a `UITableViewCell` or `UICollectionViewCell` subclass. Code samples are otherwise similar to the above.

### Using a Custom Subclass of UI*ViewCell

Create a custom subclass of `UITableViewCell` or `UICollectionViewCell`, with or without the XIB file. Make sure to instantiate `-initWithStyle: reuseIdentifier:` to instantiate a `UITableViewCell` or `-initWithFrame:` to instantiate a `UICollectionViewCell`. You can then hook the custom class up to the implementation of `FirebaseTableViewDataSource`.

#### Objective-C UITableView and UICollectionView with Custom Subclasses of UI*ViewCell
```objective-c
self.dataSource = [[FirebaseTableViewDataSource alloc] initWithRef:firebaseRef cellClass:[YourCustomClass class] cellReuseIdentifier:@"<YOUR-REUSE-IDENTIFIER>" view:self.tableView];

[self.dataSource populateCellWithBlock:^(YourCustomClass *cell, FDataSnapshot *snap) {
  // Populate custom cell as you see fit, like as below
  cell.yourCustomLabel.text = snap.key;
}];

[self.tableView setDataSource:self.dataSource];
```

```objective-c
self.dataSource = [[FirebaseCollectioneViewDataSource alloc] initWithRef:firebaseRef cellClass:[YourCustomClass class] cellReuseIdentifier:@"<YOUR-REUSE-IDENTIFIER>" view:self.CollectionView];

[self.dataSource populateCellWithBlock:^(YourCustomClass *cell, FDataSnapshot *snap) {
  // Populate cell as you see fit
  cell.customView = customView;
}];

[self.collectionView setDataSource:self.dataSource];
```

#### Swift UITableView and UICollectionView with Custom Subclasses of UI*ViewCell
```swift
self.dataSource = FirebaseTableViewDataSource(ref: firebaseRef cellClass: YourCustomClass.self cellReuseIdentifier: @"<YOUR-REUSE-IDENTIFIER>" view: self.tableView)

self.dataSource.populateCellWithBlock { (cell: YourCustomClass, obj: NSObject) -> Void in
  // Populate cell as you see fit, like as below
  cell.yourCustomLabel.text = snap.key;
}

self.tableView.dataSource = self.dataSource;
```

```swift
self.dataSource = FirebaseCollectionViewDataSource(ref: firebaseRef cellClass: YourCustomClass.self cellReuseIdentifier: @"<YOUR-REUSE-IDENTIFIER>" view: self.collectionView)

self.dataSource.populateCellWithBlock { (cell: YourCustomClass, obj: NSObject) -> Void in
  // Populate cell as you see fit
  cell.customView = customView;
}

self.collectionView.dataSource = self.dataSource;
```

### Using a Custom XIB

Create a custom XIB file and hook it up to the prototype cell. You can then use this like any other UITableViewCell, either using custom tags or by using the custom class associated with the XIB.

#### Objective-C UITableView and UICollectionView with Custom XIB
```objective-c
self.dataSource = [[FirebaseTableViewDataSource alloc] initWithRef:firebaseRef nibNamed:@"<YOUR-XIB>" cellReuseIdentifier:@"<YOUR-REUSE-IDENTIFIER>" view:self.tableView];

[self.dataSource populateCellWithBlock:^(UITableViewCell *cell, FDataSnapshot *snap) {
  // Use tags to populate custom properties, or use properties of a custom cell, if applicable
  UILabel *yourCustomLabel = (UILabel *)[cell.contentView viewWithTag:<YOUR-TAG>];
  yourCustomLabel.text = snap.key
}];

[self.tableView setDataSource:self.dataSource];
```

```objective-c
self.dataSource = [[FirebaseCollectionViewDataSource alloc] initWithRef:firebaseRef nibNamed:@"<YOUR-XIB>" cellReuseIdentifier:@"<YOUR-REUSE-IDENTIFIER>" view:self.collectionView];

[self.dataSource populateCellWithBlock:^(UICollectionViewCell *cell, FDataSnapshot *snap) {
  // Use tags to populate custom properties, or use properties of a custom cell, if applicable
  UILabel *yourCustomLabel = (UILabel *)[cell.contentView viewWithTag:<YOUR-TAG>];
  yourCustomLabel.text = snap.key
}];

[self.tableView setDataSource:self.dataSource];
```

#### Swift UITableView and UICollectionView with Custom XIB
```swift
self.dataSource = FirebaseTableViewDataSource(ref: firebaseRef nibNamed: "<YOUR-XIB>" cellReuseIdentifier: @"<YOUR-REUSE-IDENTIFIER>" view: self.tableView)

self.dataSource.populateCellWithBlock { (cell: UITableViewCell, obj: NSObject) -> Void in
  // Use tags to populate custom properties, or use properties of a custom cell, if applicable
  let yourCustomLabel: UILabel = cell.contentView.viewWithTag(<YOUR-TAG>) as! UILabel
  yourCustomLabel.text = snap.key
}

self.tableView.dataSource = self.dataSource;
```

```swift
self.dataSource = FirebaseCollectionViewDataSource(ref: firebaseRef cellClass: YourCustomClass.self cellReuseIdentifier: @"<YOUR-REUSE-IDENTIFIER>" view: self.collectionView)

self.dataSource.populateCellWithBlock { (cell: YourCustomClass, obj: NSObject) -> Void in
  // Use tags to populate custom properties, or use properties of a custom cell, if applicable
  let yourCustomLabel: UILabel = cell.contentView.viewWithTag(<YOUR-TAG>) as! UILabel
  yourCustomLabel.text = snap.key
}

self.collectionView.dataSource = self.dataSource;
```

## Understanding FirebaseUI Core's Internals

FirebaseUI has several building blocks that developers should understand before building additional functionality on top of FirebaseUI, including a synchronized array `FirebaseArray` and a generic data source superclass `FirebaseDataSource` from which `FirebaseTableViewDataSource` and `FirebaseCollectionViewDataSource` or other custom view classes subclass.

### FirebaseArray and the FirebaseArrayDelegate Protocol

`FirebaseArray` is synchronized array connecting a Firebase Ref with an array. It surfaces Firebase events through the FirebaseArrayDelegate Protocol. It is generally recommended that developers not directly access `FirebaseArray` without routing it through a custom data source, though if this is desired, check out `FirebaseDataSource` below.

#### Objective-C
```objective-c
Firebase *firebaseRef = [[Firebase alloc] initWithUrl:@"https://<YOUR-FIREBASE-APP>.firebaseio.com/"];
FirebaseArray *array = [[FirebaseArray alloc] initWithRef:firebaseRef];
```

#### Swift
```swift
let firebaseRef = Firebase(url: "https://<YOUR-FIREBASE-APP>.firebaseio.com/")
let array = FirebaseArray(ref: firebaseRef)
```

### FirebaseDataSource

FirebaseDataSource acts as a generic data source by providing common information, such as the count of objects in the data source, and by requiring subclasses to implement FirebaseArrayDelegate methods as appropriate to the view. This class should never be instantiated, but should be subclassed when creating a specific adapter for a View. [FirebaseTableViewDataSource](https://github.com/firebase/FirebaseUI-iOS/blob/master/FirebaseUI/Implementation/FirebaseTableViewDataSource.m) and [FirebaseCollectionViewDataSource](https://github.com/firebase/FirebaseUI-iOS/blob/master/FirebaseUI/Implementation/FirebaseCollectionViewDataSource.m) are examples of this. FirebaseDataSource is essentially a wrapper around a FirebaseArray.

## FirebaseUI Auth API

### FirebaseAppDelegate
`FirebaseAppDelegate` is replacement for the standard `AppDelegate` and provides setup features necessary for authentication to work. If you plan on using FirebaseUI authentication features, your `AppDelegate` should subclass `FirebaseAppDelegate` like so:

#### Objective-C
```objective-c
// AppDelegate.h
#import <UIKit/UIKit.h>
#import <FirebaseUI/FirebaseAppDelegate.h>

@interface AppDelegate : FirebaseAppDelegate

@end

// AppDelegate.m
#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [super application:application didFinishLaunchingWithOptions:launchOptions];
  // Override point for customization after application launch.

  return YES;
}
...

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(nonnull id)annotation {
  [super application:app openURL:url sourceApplication:sourceApplication annotation:annotation];
  // Override point for customization.

  return YES;
}

@end
```

#### Swift
```swift
import UIKit
import FirebaseUI

@UIApplicationMain
class AppDelegate: FirebaseAppDelegate {

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    super.application(application, launchOptions);
    // Override point for customization after application launch.

    return true
  }
  ...

  func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
    super.application(application, url, sourceApplication, annotation);
    // Override point for customization.

    return true
  }
}
```

### FirebaseLoginViewController
`FirebaseLoginViewContoller` quickly adds a headful UI flow to your application. This flow supports email/password login, as well as social providers (Facebook, Google, Twitter). Using this, you can easily guide users through the login journey, get the current user's state, and log the user out. There are two main scenerios this controller can be used in:
  1. A captive login portal: launches on app start, developer must specify dismissal behavior
  2. A login modal view: launches on user action, developer may specify dismissal behavior or use built in FirebaseUI behavior

This view looks like:

![FirebaseLoginViewController with all providers enabled](https://github.com/firebase/FirebaseUI-iOS/blob/master/docs/FirebaseLoginViewController.png)

For creating a captive portal, we recommend creating the `FirebaseLoginViewController` and enabling providers in `viewDidLoad`, but don't display it until the view has been created (`viewWillAppear` or later!). It is best to make the `FirebaseLoginViewController` a property on your view controller so it will be retained and acessible by other methods in your class.

#### Objective-C
```objective-c
- (void)viewDidLoad {
  [super viewDidLoad];

  Firebase *firebaseRef = [[Firebase alloc] initWithUrl:@"https://<YOUR-FIREBASE-APP>.firebaseio.com/"];

  self.loginViewController = [[FirebaseLoginViewController alloc] initWithRef:firebaseRef];
  [self.loginViewController enableProvider:FAuthProviderFacebook];
  [self.loginViewController enableProvider:FAuthProviderGoogle];
  [self.loginViewController enableProvider:FAuthProviderTwitter];
  [self.loginViewController enableProvider:FAuthProviderPassword];
  // Scenario 1: Set up captive portal login flow
  [self.loginViewController didDismissWithBlock:^(FAuthData *user, NSError *error) {
    if (user) {
      // Handle user case
    } else if (error) {
      // Handle error case
    } else {
      // Handle cancel case
    }
  }];

  // Scenario 2: Set up user action based login flow
  [loginButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
  [logoutButton addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
}

// Scenario 1: Application launches login flow, handles dismissal and routing in `didDismissWithBlock:`
- (void)viewDidAppear:(BOOL)animated {
  if (![self.loginViewController currentUser]) {
    [self presentViewController:self.loginViewController animated:YES completion:nil];
  }
}

// Scenario 2: User action launches login flow, dismissal and routing handled by `FirebaseLoginViewController`
- (void)login {
  if (![self.loginViewController currentUser]) {
    [self presentViewController:self.loginViewController animated:YES completion:nil];
  }
}

- (void)logout {
  if ([self.loginViewController currentUser]) {
    [self.loginViewController logout];
  }
}
```

#### Swift
```swift
override func viewDidLoad() {
  super.viewDidLoad()

  let firebaseRef = Firebase(url: "https://<YOUR-FIREBASE-APP>.firebaseio.com/")

  self.loginViewController = FirebaseLoginViewController(ref: firebaseRef)
  self.loginViewController.enableProvider(FAuthProvider.Facebook)
  self.loginViewController.enableProvider(FAuthProvider.Google)
  self.loginViewController.enableProvider(FAuthProvider.Twitter)
  self.loginViewController.enableProvider(FAuthProvider.Password)
  // Scenario 1: Set up captive portal login flow
  self.loginViewController.didDismissWithBlock { (user: FAuthData, error: NSError) -> Void in
    if (user) {
      // Handle user case
    } else if (error) {
      // Handle error case
    } else {
      // Handle cancel case
    }
  }

  // Scenario 2: Set up user action based login flow
  loginButton.addTarget(self, action: "login", forControlEvents: UIControlEvents.TouchUpInside)
  logoutButton.addTarget(self, action: "logout", forControlEvents: UIControlEvents.TouchUpInside)
}

// Scenario 1: Application launches login flow, handles dismissal and routing in `didDismissWithBlock:`
override func viewDidAppear(animated: Bool) {
  if (!self.loginViewController.currentUser()) {
    self.presentViewController(self.loginViewcontroller, animated: true, completion: nil)
  }
}

// Scenario 2: User action launches login flow, dismissal and routing handled by `FirebaseLoginViewController`
func login() {
  if (!self.loginViewController.currentUser()) {
    self.presentViewController(self.loginViewcontroller, animated: true, completion: nil)
  }
}

func logout() {
  if (self.loginViewController.currentUser()) {
    self.loginViewController.logout()
  }
}
```

### FirebaseFacebookAuthProvider

`FirebaseFacebookAuthProvider` is a wrapper around Facebook login. To enable this, visit the Auth tab of your Firebase Dashboard and enable this provider by checking the checkbox, then [create a new Facebook project](https://developers.facebook.com/docs/ios/getting-started) and follow the installation instructions. You will also have to add "FacebookAppID" and "FacebookDisplayName" keys as well as several URL schemes to your "Info.plist". For more information about setup, see the Firebase [Facebook authentication docs](https://www.firebase.com/docs/ios/guide/login/facebook.html).

#### Objective-C
```objective-c
Firebase *firebaseRef = [[Firebase alloc] initWithUrl:@"https://<YOUR-FIREBASE-APP>.firebaseio.com/"];
FirebaseFacebookAuthProvider *facebookProvider = [[FirebaseFacebookAuthProvider alloc] initWithRef:firebaseRef authDelegate:self];
[facebookProvider login];
...
[facebookProvider logout];
```

#### Swift
```swift
let firebaseRef = Firebase(url: "https://<YOUR-FIREBASE-APP>.firebaseio.com/")
let facebookProvider = FirebaseFacebookAuthProvider(ref: firebaseRef, authDelegate: self)
facebookProvider.login()
...
facebookProvider.logout()
```
### FirebaseGoogleAuthProvider

`FirebaseGoogleAuthProvider` is a wrapper around Google login. To enable this, visit the Auth tab of your Firebase Dashboard and enable this provider by checking the checkbox, then [create a new Google Project](https://developers.google.com/identity/sign-in/ios/start), download `GoogleServices-Info.plist`, and include it in your projct. You will also have to add several URL schemes to your "Info.plist". For more information about setup, see the Firebase [Google authentication docs](https://www.firebase.com/docs/ios/guide/login/google.html).

#### Objective-C
```objective-c
Firebase *firebaseRef = [[Firebase alloc] initWithUrl:@"https://<YOUR-FIREBASE-APP>.firebaseio.com/"];
FirebaseGoogleAuthProvider *googleProvider = [[FirebaseGoogleAuthProvider alloc] initWithRef:firebaseRef authDelegate:self uiDelegate:self];
[googleProvider login];
...
[googleProvider logout];
```

#### Swift
```swift
let firebaseRef = Firebase(url: "https://<YOUR-FIREBASE-APP>.firebaseio.com/")
let googleProvider = FirebaseGoogleAuthProvider(ref: firebaseRef, authDelegate: self, uiDelegate: self)
googleProvider.login()
...
googleProvider.logout()
```

### FirebaseTwitterAuthProvider

`FirebaseTwitterAuthProvider` is a wrapper around Twitter login. To enable this, visit the Auth tab of your Firebase Dashboard and enable this provider by checking the checkbox, then [create a new Twitter project](https://apps.twitter.com/) and enter your Twitter API Key and Secret on this page. You will also have to add the key "TwitterApiKey" to your apps "Info.plist". For more information about setup, see the Firebase [Twitter authentication docs](https://www.firebase.com/docs/ios/guide/login/twitter.html).

#### Objective-C
```objective-c
Firebase *firebaseRef = [[Firebase alloc] initWithUrl:@"https://<YOUR-FIREBASE-APP>.firebaseio.com/"];
FirebaseTwitterAuthProvider *twitterProvider = [[FirebaseTwitterAuthProvider alloc] initWithRef:firebaseRef authDelegate:self twitterDelegate:self];
[twitterProvider login];
...
[twitterProvider logout];
```

#### Swift
```swift
let firebaseRef = Firebase(url: "https://<YOUR-FIREBASE-APP>.firebaseio.com/")
let twitterProvider = FirebaseTwitterAuthProvider(ref: firebaseRef, authDelegate: self, twitterDelegate: self)
twitterProvider.login()
...
twitterProvider.logout()
```

### FirebasePasswordAuthProvider

`FirebasePasswordAuthProvider` is a wrapper around Firebase email/password login. To enable this, visit the Auth tab of your Firebase Dashboard and enable this provider by checking the checkbox. For more information about setup, see the Firebase [Email/Password authentication docs](https://www.firebase.com/docs/ios/guide/login/password.html).

#### Objective-C
```objective-c
Firebase *firebaseRef = [[Firebase alloc] initWithUrl:@"https://<YOUR-FIREBASE-APP>.firebaseio.com/"];
FirebasePasswordAuthProvider *passwordProvider = [[FirebasePasswordAuthProvider alloc] initWithRef:firebaseRef authDelegate:self];
[passwordProvider loginWithEmail:@"email" andPassword:@"password"];
...
[passwordProvider logout];
```

#### Swift
```swift
let firebaseRef = Firebase(url: "https://<YOUR-FIREBASE-APP>.firebaseio.com/")
let passwordProvider = FirebasePasswordAuthProvider(ref: firebaseRef, authDelegate: self)
passwordProvider.login(email: "email", password: "password")
...
passwordProvider.login()
```

## Understanding FirebaseUI Auth's Internals

### FirebaseAuthProvider

`FirebaseAuthProvider` is a superclass for all identity providers, providing a default constructor `[FirebaseAuthProvider initWithRef:authDelegate:]` as well as `login`, `logout`, and `configureProvider` methods to facilitate standard authentication across providers. `login` and `configureProvider` are unimplemented in the base implementation and will thrown an exception if called, so each provider should override these methods. `logout` is implemented to unauthenticate the given Firebase reference, and should always be called using `[super logout]` at the end of any subclass implementation.

`FirebaseAuthProvider` also registers a singleton authentication listener that monitors the global authentication state across all providers and will route `authProvider:onLogin:` and `onLogout` events appropriately.

### FirebaseAuthDelegate and TwitterAuthDelegate protocols

Every authentication event is plumbed through `FirebaseAuthDelegate`, which has four methods:
  1. `[FirebaseAuthDelegate authProvider:onLogin:]`
  1. `[FirebaseAuthDelegate onLogout:]`
  1. `[FirebaseAuthDelegate authProvider:onUserError:]`
  1. `[FirebaseAuthDelegate authProvider:onProviderError:]`

The first two methods, for login and logout, are required for classes implementing the `FirebaseAuthDelegate` protcol, while the latter two are optional though strongly recommended. All authentication events, regardless of provider, will go through these methods.

In general, user errors (such as invalid password or cancellation of an auth request on behalf of a user) are recoverable and should prompt the user to retry the authentication, while provider errors (such as improper configuration or issues on the provider side) are usually outside of the user's control and should guide the user down a separate path (disabling the provider, temporarily disabling the app, etc.).

`TwitterAuthDelegate` is included as a special case for dealing with zero or multiple Twitter accounts on the same device, as developers need to either prompt the user to create a Twitter account (or sign in on the phone), or select from multiple accounts. The `[TwitterAuthDelegate createTwitterAccount]` and `[TwitterAuthDelegate selectTwitterAccount:]` methods can be used for these purposes.

### Creating custom headful UI via FirebaseLoginViewController
`FirebaseLoginViewController` is one implementation of a simple headful UI built on top of FirebaseUI's auth components. This class contains Provider methods for the different providers, as well as state about the current provider (and therefore the user), which allows for synchronous calls to `currentUser` and `logout` from outside of the view controller while treating `FirebaseLoginViewController` as a single source of truth for auth state.

All UI elements in FirebaseLoginViewController are reconfigurable (with the exception of the button colors), so theming the UI to your application shouldn't be difficult. If the theme doesn't fit, feel free to use the concepts of `FirebaseLoginViewController` to create your own authentication controller.

## Local Setup

If you'd like to contribute to FirebaseUI for iOS, you'll need to run the
following commands to get your environment set up:

```bash
$ git clone https://github.com/firebase/FirebaseUI-iOS.git
$ cd FirebaseUI-iOS
$ ./setup.sh
```

Note that `setup.sh` pulls in a number of provider frameworks (Facebook, Google), which need to be pulled in for local development. The debug build and framework release have the flag `LOCAL_BUILD=1` which uses the local frameworks installed via `setup.sh`, while the CocoaPods release doesn't have this flag set, so the appropriate Pod `#import` statements are used.

FirebaseUI makes use of Xcode 7 features such as lightweight generics and `__kindof` annotations, but it should be backwards compatible to Xcode 6 thanks to [XcodeMacros.h](https://github.com/firebase/FirebaseUI-iOS/blob/master/FirebaseUI/XcodeMacros.h).

## Deployment

- `git pull` to update the master branch
- tag and push the tag for this release
- `./build.sh` to build a binary
- `./create-docs.sh` to generate docs
- From your macbook that already has been granted permissions to FirebaseUI CocoaPods, do `pod trunk push`
- `firebase deploy` the FirebaseUI website with newly generated docs

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
1. Submit a pull request and cc @davideast or @mcdonamp
