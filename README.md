# FirebaseUI for iOS — UI Bindings for Firebase

FirebaseUI is an open-source library for iOS that allows you to quickly connect common UI elements to the Firebase [Firebase](https://www.firebase.com/?utm_source=firebaseui-ios) database for data storage, allowing views to be updated in realtime as they change, and providing simple interfaces for common tasks like displaying lists or collections of items.

A compatible FirebaseUI client is also available for [Android](https://github.com/firebase/FirebaseUI-Android).

## Downloading FirebaseUI for iOS

We recommend using [CocoaPods](http://cocoapods.org/?q=firebaseui-ios), add
the following to your `Podfile`:

```
pod 'FirebaseUI', '>= 0.1.0'
```

Otherwise, you can download the latest version of the [FirebaseUI.framework from the releases
page](https://github.com/firebase/FirebaseUI-iOS/releases) or include the FirebaseUI
Xcode project from this repo in your project. You also need to [add the Firebase
framework](https://www.firebase.com/docs/ios-quickstart.html?utm_source=firebaseui-ios) to your project.

### Using FirebaseUI with Swift

In order to use FirebaseUI in a Swift project, you'll also need to setup a bridging
header, in addition to adding the Firebase and FirebaseUI frameworks
to your project. To do that, [follow these instructions](https://www.firebase.com/docs/ios/guide/setup.html#section-swift), and then add the following line to your bridging header:

````objective-c
#import <FirebaseUI/FirebaseUI.h>
````

## Getting Started with Firebase

FirebaseUI requires Firebase in order to store location data. You can [sign up here for a free
account](https://www.firebase.com/signup/?utm_source=firebaseui-ios).

## FirebaseUI for iOS Quickstart

This is a quickstart on how to use FirebaseUI's core features to speed up iOS development with Firebase.

### FirebaseTableViewDataSource

FirebaseTableViewDataSource implements the UITableViewDataSource protocol to automatically use Firebase as a DataSource for your UITableView.

##### Objective-C
```objective-c
MyViewController.h
...
@property (strong, nonatomic) Firebase *ref;
@property (strong, nonatomic) FirebaseTableViewDataSource *dataSource;
```

```objective-c
MyViewController.m
...
self.firebaseRef = [[Firebase alloc] initWithUrl:@"https://<your-firebase-app>.firebaseio.com/"];
self.dataSource = [[FirebaseTableViewDataSource alloc] initWithRef:firebaseRef reuseIdentifier:@"<your-reuse-identifier>" view:self.tableView];

[self.dataSource populateCellWithBlock:^(UITableViewCell *cell, FDataSnapshot *snap) {
  // Populate cell as you see fit, like as below
  cell.textLabel.text = snap.key;
}];

[self.tableView setDataSource:self.dataSource];
```

## Creating Custom TableViews with FirebaseTableViewDataSource

You can use FirebaseTableViewDataSource in several ways to create custom UITableViews. For more information on how to create custom UITableViews, check out the following tutorial on [TutsPlus](http://code.tutsplus.com/tutorials/ios-sdk-crafting-custom-uitableview-cells--mobile-15702).

### Using the Default UITableViewCell Implementation

You can use the default UITableViewCell implementation to get up and running quickly. This allows for the `cell.textLabel` and the `cell.detailTextLabel` to be used directly out of the box.

```objective-c
self.dataSource = [[FirebaseTableViewDataSource alloc] initWithRef:firebaseRef reuseIdentifier:@"<your-reuse-identifier>" view:self.tableView];

[self.dataSource populateCellWithBlock:^(UITableViewCell *cell, FDataSnapshot *snap) {
  // Populate cell as you see fit, like as below
  cell.textLabel.text = snap.key;
}];

[self.tableView setDataSource:self.dataSource];
```

### Using Storyboards and Prototype Cells

Create a storyboard that has either a UITableViewController or a UIViewController with a UITableView. Drag a prototype cell onto the UITableView and give it a custom ReuseIdentifier. Drag and other properties onto the cell and associate them with properties of a UITableViewCell subclass.

```objective-c
self.dataSource = [[FirebaseTableViewDataSource alloc] initWithRef:firebaseRef reuseIdentifier:@"<your-reuse-identifier>" view:self.tableView];

[self.dataSource populateCellWithBlock:^(UITableViewCell *cell, FDataSnapshot *snap) {
  // Populate cell as you see fit, like as below
  cell.textLabel.text = snap.key;
}];

[self.tableView setDataSource:self.dataSource];
```

### Using a Custom Subclass of UITableViewCell

Create a custom subclass of UITableViewCell, with or without the XIB file. Make sure to instantiate `-initWithStyle: reuseIdentifier:` to instantiate the Cells. You can then hook the custom class up to the implementation of FirebaseTableViewDataSource.

```objective-c
self.dataSource = [[FirebaseTableViewDataSource alloc] initWithRef:firebaseRef cellClass:[YourCustomCell class] reuseIdentifier:@"<your-reuse-identifier>" view:self.tableView];

[self.dataSource populateCellWithBlock:^(YourCustomCell *cell, FDataSnapshot *snap) {
  // Populate your custom cell as you see fit, like as below
  cell.customLabel.text = snap.key;
}];

[self.tableView setDataSource:self.dataSource];
```

### Using a Custom XIB

Create a custom XIB file and add it to the cell prototype. You can then use this like any other UITableViewCell, though with custom tags if desired.

```objective-c
self.dataSource = [[FirebaseTableViewDataSource alloc] initWithRef:firebaseRef nibNamed:@"<your-xib>" reuseIdentifier:@"<your-reuse-identifier>" view:self.tableView];

[self.dataSource populateCellWithBlock:^(UITableViewCell *cell, FDataSnapshot *snap) {
  // Populate your cell as you see fit, like as below
  cell.textLabel.text = snap.key;

  // Use tags to populate custom properties
  UILabel *myCustomLabel = (UILabel *)[cell.contentView viewWithTag:<your-tag>];
  myCustomLabel.text = snap.key
}];

[self.tableView setDataSource:self.dataSource];
```

## Understanding FirebaseUI's Internals

FirebaseUI has several building blocks that developers should understand before building additional functionality on top of FirebaseUI, including a synchronized array `FirebaseArray.*` and a generic data source superclass `FirebaseDataSource.*` from which FirebaseTableViewDataSource or other custom view classes subclass.

### FirebaseArray and the FirebaseArrayDelegate Protocol

FirebaseArray is synchronized array connecting a Firebase Ref with an array. It surfaces Firebase events through the FirebaseArrayDelegate Protocol. It is generally recommended that developers not directly access FirebaseArray without routing it through a custom data source.

##### Objective-C
```objective-c
FirebaseArray *array = [[FirebaseArray alloc] initWithRef:@"https://<your-firebase-app>.firebaseio.com/"];

```

### FirebaseDataSource

FirebaseDataSource acts as a generic data source by providing common information, such as the count of objects in the data source, and by requiring subclasses to implement FirebaseArrayDelegate methods as appropriate to the view. This class should never be instantiated, but should be subclassed when creating a specific adapter for a View. [FirebaseTableViewDataSource](https://github.com/firebase/FirebaseUI-iOS/blob/master/FirebaseUI/Implementation/FirebaseTableViewDataSource.m) is an example of this.

## Local Setup

If you'd like to contribute to FirebaseUI for iOS, you'll need to run the
following commands to get your environment set up:

```bash
$ git clone https://github.com/firebase/FirebaseUI-iOS.git
$ cd FirebaseUI-iOS
$ ./setup.sh
```

## Deployment

- `git pull` to update the master branch
- tag and push the tag for this release
- `./build.sh` to build a binary
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
1. Submit a pull request.
