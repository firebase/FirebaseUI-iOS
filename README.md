# FirebaseUI for iOS — UI Bindings for Firebase

FirebaseUI is an open-source library for iOS that allows you to quickly connect common UI elements to the [Firebase](https://www.firebase.com/?utm_source=firebaseui-ios) database for data storage, allowing views to be updated in realtime as they change, and providing simple interfaces for common tasks like displaying lists or collections of items.

A compatible FirebaseUI client is also available for [Android](https://github.com/firebase/FirebaseUI-Android).

## Installing FirebaseUI for iOS

We recommend using [CocoaPods](http://cocoapods.org/?q=firebaseui-ios), add
the following to your `Podfile`:

```
pod 'FirebaseUI', '~> 0.2'
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

Class  | Description
------------- | -------------
FirebaseTableViewDataSource | Data source to bind a Firebase query to a UITableView
FirebaseCollectionViewDataSource | Data source to bind a Firebase query to a UICollectionView
FirebaseArray | Keeps an array synchronized to a Firebase query
FirebaseDataSource | Generic superclass to create a custom data source

For a more in-depth explanation of each of the above, check the usage instructions below or read the [docs](https://firebaseui.firebaseapp.com/docs/ios/index.html).

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

## Understanding FirebaseUI's Internals

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

## Local Setup

If you'd like to contribute to FirebaseUI for iOS, you'll need to run the
following commands to get your environment set up:

```bash
$ git clone https://github.com/firebase/FirebaseUI-iOS.git
$ cd FirebaseUI-iOS
$ ./setup.sh
```

FirebaseUI makes use of XCode 7 features such as lightweight generics and `__kindof` annotations, but it should be backwards compatible to XCode 6 thanks to [XCodeMacros.h](https://github.com/firebase/FirebaseUI-iOS/blob/master/FirebaseUI/XCodeMacros.h).

## Deployment

- `git pull` to update the master branch
- tag and push the tag for this release
- `./build.sh` to build a binary
- `./create-docs.sh` to generate docs
- From your macbook that already has been granted permissions to FirebaseUI Cocoapods, do `pod trunk push`
- Update [firebase-versions](https://github.com/firebase/firebase-clients/blob/master/versions/firebase-versions.json) with the changelog for this release.

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
