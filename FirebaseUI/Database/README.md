# FirebaseUI/Database for iOS — UI Bindings for the Firebase Realtime Database

FirebaseUI/Database allows you to quickly connect common UI elements to the [Firebase Realtime Database](https://firebase.google.com/docs/database?utm_source=firebaseui-ios) for data storage, allowing views to be updated in realtime as they change, and providing simple interfaces for common tasks like displaying lists or collections of items.

## FirebaseUI Database
Provides core data binding capabilities as well as specific datasources for lists of data. Skip to the [Core API overview](https://github.com/firebase/firebaseui-ios#firebaseui-core-api) for more information.

Class  | Description
------------- | -------------
FirebaseTableViewDataSource | Data source to bind a Firebase query to a UITableView
FirebaseCollectionViewDataSource | Data source to bind a Firebase query to a UICollectionView
FirebaseArray | Keeps an array synchronized to a Firebase query
FirebaseDataSource | Generic superclass to create a custom data source

For a more in-depth explanation of each of the above, check the usage instructions below or read the [docs](https://firebaseui.firebaseapp.com/docs/ios/index.html).

## FirebaseUI Database API
### FirebaseTableViewDataSource

`FirebaseTableViewDataSource` implements the `UITableViewDataSource` protocol to automatically use Firebase as a data source for your `UITableView`.

#### Objective-C
```objc
// YourViewController.h

@property (strong, nonatomic) FIRDatabaseReference *firebaseRef;
@property (strong, nonatomic) FirebaseTableViewDataSource *dataSource;
```

```objective-c
// YourViewController.m

self.firebaseRef = [[FIRDatabase database] reference];
self.dataSource = [[FirebaseTableViewDataSource alloc] initWithRef:self.firebaseRef cellReuseIdentifier:@"<YOUR-REUSE-IDENTIFIER>" view:self.tableView];
self.tableView.dataSource = self.dataSource;

[self.dataSource populateCellWithBlock:^(UITableViewCell *cell, FIRDataSnapshot *snap) {
  // Populate cell as you see fit, like as below
  cell.textLabel.text = snap.key;
}];
```

#### Swift
```swift
// YourViewController.swift

let firebaseRef = FIRDatabase.database().reference()
var dataSource: FirebaseTableViewDataSource!

self.dataSource = FirebaseTableViewDataSource(ref: self.firebaseRef, cellReuseIdentifier: "<YOUR-REUSE-IDENTIFIER>", view: self.tableView)
self.tableView.dataSource = self.dataSource

self.dataSource.populateCellWithBlock { (cell: UITableViewCell, obj: NSObject) -> Void in
  let snap = obj as! FIRDataSnapshot

  // Populate cell as you see fit, like as below
  cell.textLabel?.text = snap.key as String
}
```

### FirebaseCollectionViewDataSource

`FirebaseCollectionViewDataSource` implements the `UICollectionViewDataSource` protocol to automatically use Firebase as a data source for your `UICollectionView`.

#### Objective-C
```objective-c
// YourViewController.h

@property (strong, nonatomic) FIRDatabaseReference *firebaseRef;
@property (strong, nonatomic) FirebaseCollectionViewDataSource *dataSource;
```

```objective-c
// YourViewController.m

self.firebaseRef = [[FIRDatabase database] reference];
self.dataSource = [[FirebaseTableViewDataSource alloc] initWithRef:self.firebaseRef cellReuseIdentifier:@"<YOUR-REUSE-IDENTIFIER>" view:self.CollectionView];
self.collectionView.dataSource = self.dataSource;

[self.dataSource populateCellWithBlock:^(UICollectionViewCell *cell, FIRDataSnapshot *snap) {
  // Populate cell as you see fit, like as below
  cell.backgroundColor = [UIColor blueColor];
}];
```

#### Swift
```swift
// YourViewController.swift

let firebaseRef = FIRDatabase.database().reference()
var dataSource: FirebaseCollectionViewDataSource!

self.dataSource = FirebaseCollectionViewDataSource(ref: self.firebaseRef, cellReuseIdentifier: "<YOUR-REUSE-IDENTIFIER>", view: self.collectionView)

self.dataSource.populateCellWithBlock { (cell: UICollectionViewCell, obj: NSObject) -> Void in
  let snap = obj as! FIRDataSnapshot

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
self.tableView.dataSource = self.dataSource

[self.dataSource populateCellWithBlock:^(UITableViewCell *cell, FIRDataSnapshot *snap) {
  // Populate cell as you see fit, like as below
  cell.textLabel.text = snap.key;
}];
```

```objective-c
self.dataSource = [[FirebaseCollectioneViewDataSource alloc] initWithRef:firebaseRef cellReuseIdentifier:@"<YOUR-REUSE-IDENTIFIER>" view:self.CollectionView];
self.collectionView.dataSource = self.dataSource;

[self.dataSource populateCellWithBlock:^(UICollectionViewCell *cell, FIRDataSnapshot *snap) {
  // Populate cell as you see fit by adding subviews as appropriate
  [cell.contentView addSubview:customView];
}];
```

#### Swift UITableView and UICollectionView with Default UI*ViewCell
```swift
self.dataSource = FirebaseTableViewDataSource(ref: firebaseRef cellReuseIdentifier: @"<YOUR-REUSE-IDENTIFIER>" view: self.tableView)
self.tableView.dataSource = self.dataSource

self.dataSource.populateCellWithBlock { (cell: UITableViewCell, obj: NSObject) -> Void in
  let snap = obj as! FIRDataSnapshot
  // Populate cell as you see fit, like as below
  cell.textLabel.text = snap.key
}
```

```swift
self.dataSource = FirebaseCollectionViewDataSource(ref: firebaseRef cellReuseIdentifier: @"<YOUR-REUSE-IDENTIFIER>" view: self.collectionView)
self.collectionView.dataSource = self.dataSource

self.dataSource.populateCellWithBlock { (cell: UICollectionViewCell, obj: NSObject) -> Void in
  // Populate cell as you see fit by adding subviews as appropriate
  cell.contentView.addSubview(customView)
}
```

### Using Storyboards and Prototype Cells

Create a storyboard that has either a `UITableViewController`, `UICollectionViewController` or a `UIViewController` with a `UITableView` or `UICollectionView`. Drag a prototype cell onto the `UITableView` or `UICollectionView` and give it a custom reuse identifier which matches the reuse identifier being used when instantiating the `Firebase*ViewDataSource`. *When using prototype cells, make sure to use `prototypeReuseIdentifier` instead of `cellReuseIdentifier`*.

Drag and other properties onto the cell and associate them with properties of a `UITableViewCell` or `UICollectionViewCell` subclass. Code samples are otherwise similar to the above.

### Using a Custom Subclass of UI*ViewCell

Create a custom subclass of `UITableViewCell` or `UICollectionViewCell`, with or without the XIB file. Make sure to implement `-initWithStyle: reuseIdentifier:` to instantiate a `UITableViewCell` or `-initWithFrame:` to instantiate a `UICollectionViewCell`. You can then hook the custom class up to the implementation of `FirebaseTableViewDataSource`.

#### Objective-C UITableView and UICollectionView with Custom Subclasses of UI*ViewCell
```objective-c
self.dataSource = [[FirebaseTableViewDataSource alloc] initWithRef:firebaseRef cellClass:[YourCustomClass class] cellReuseIdentifier:@"<YOUR-REUSE-IDENTIFIER>" view:self.tableView];
self.tableView.dataSource = self.dataSource;

[self.dataSource populateCellWithBlock:^(YourCustomClass *cell, FIRDataSnapshot *snap) {
  // Populate custom cell as you see fit, like as below
  cell.yourCustomLabel.text = snap.key;
}];
```

```objective-c
self.dataSource = [[FirebaseCollectioneViewDataSource alloc] initWithRef:firebaseRef cellClass:[YourCustomClass class] cellReuseIdentifier:@"<YOUR-REUSE-IDENTIFIER>" view:self.CollectionView];
self.collectionView.dataSource = self.dataSource;

[self.dataSource populateCellWithBlock:^(YourCustomClass *cell, FDataSnapshot *snap) {
  // Populate cell as you see fit
  cell.customView = customView;
}];
```

#### Swift UITableView and UICollectionView with Custom Subclasses of UI*ViewCell
```swift
self.dataSource = FirebaseTableViewDataSource(ref: firebaseRef cellClass: CustomCollectionViewCell.self cellReuseIdentifier: @"<YOUR-REUSE-IDENTIFIER>" view: self.tableView)
self.collectionView.dataSource = self.dataSource

self.dataSource.populateCellWithBlock { (anyCell: UITableViewCell, obj: NSObject) -> Void in
  let cell = anyCell as! CustomTableViewCell
  let snap = obj as! FIRDatabaseSnapshot

  // Populate cell as you see fit, like as below
  cell.yourCustomLabel.text = snap.key
}
```

```swift
self.dataSource = FirebaseCollectionViewDataSource(ref: firebaseRef cellClass: CustomCollectionViewCell.self cellReuseIdentifier: @"<YOUR-REUSE-IDENTIFIER>" view: self.collectionView)
self.collectionView.dataSource = self.dataSource

self.dataSource.populateCellWithBlock { (anyCell: UICollectionViewCell, obj: NSObject) -> Void in
  let snap = obj as! FIRDatabaseSnapshot
  let cell = anyCell as! CustomCollectionViewCell

  // Populate cell as you see fit
  cell.customView = customView
}
```

### Using a Custom XIB

Create a custom XIB file and hook it up to the prototype cell. You can then use this like any other UITableViewCell, for example by using the custom class associated with the XIB.

#### Objective-C UITableView and UICollectionView with Custom XIB
```objective-c
self.dataSource = [[FirebaseTableViewDataSource alloc] initWithRef:firebaseRef nibNamed:@"<YOUR-XIB>" cellReuseIdentifier:@"<YOUR-REUSE-IDENTIFIER>" view:self.tableView];
self.tableView.dataSource = self.dataSource;

[self.dataSource populateCellWithBlock:^(CustomTableViewCell *cell, FIRDataSnapshot *snap) {
  NSAssert([cell isMemberOfClass:[CustomTableViewCell class]], @"Unexpected cell type %@ in table view", NSStringFromClass([cell class]));
  cell.customTextLabel.text = snap.key;
}];
```

```objective-c
self.dataSource = [[FirebaseCollectionViewDataSource alloc] initWithRef:firebaseRef nibNamed:@"<YOUR-XIB>" cellReuseIdentifier:@"<YOUR-REUSE-IDENTIFIER>" view:self.collectionView];
self.collectionView.dataSource = self.dataSource;

[self.dataSource populateCellWithBlock:^(CustomCollectionViewCell *cell, FIRDataSnapshot *snap) {
  NSAssert([cell isMemberOfClass:[CustomCollectionViewCell class]], @"Unexpected cell type %@ in collection view", NSStringFromClass([cell class]));
  cell.customTextLabel.text = snap.key;
}];
```

#### Swift UITableView and UICollectionView with Custom XIB
```swift
self.dataSource = FirebaseTableViewDataSource(ref: firebaseRef nibNamed: "<YOUR-XIB>" cellReuseIdentifier: @"<YOUR-REUSE-IDENTIFIER>" view: self.tableView)
self.tableView.dataSource = self.dataSource

self.dataSource.populateCellWithBlock { (anyCell: UITableViewCell, obj: NSObject) -> Void in
  let cell = anyCell as! CustomTableViewCell
  let snap = obj as! FIRDataSnapshot
  cell.customTextLabel.text = snap.key
}
```

```swift
self.dataSource = FirebaseCollectionViewDataSource(ref: firebaseRef cellClass: YourCustomClass.self cellReuseIdentifier: @"<YOUR-REUSE-IDENTIFIER>" view: self.collectionView)
self.collectionView.dataSource = self.dataSource

self.dataSource.populateCellWithBlock { (anyCell: UICollectionViewCell, obj: NSObject) -> Void in
  let cell = anyCell as! CustomCollectionViewCell
  let snap = obj as! FIRDataSnapshot
  cell.customTextLabel.text = snap.key
}
```

## Understanding FirebaseUI Core's Internals

FirebaseUI has several building blocks that developers should understand before building additional functionality on top of FirebaseUI, including a synchronized array `FirebaseArray` and a generic data source superclass `FirebaseDataSource` from which `FirebaseTableViewDataSource` and `FirebaseCollectionViewDataSource` or other custom data source classes subclass.

### FirebaseArray and the FirebaseArrayDelegate Protocol

`FirebaseArray` is synchronized array connecting a Firebase Ref with an array. It surfaces Firebase events through the FirebaseArrayDelegate Protocol. It is generally recommended that developers not directly access `FirebaseArray` without routing it through a custom data source, though if this is desired, check out `FirebaseDataSource` below.

#### Objective-C
```objective-c
FIRDatabaseReference *firebaseRef = [[FIRDatabase database] reference];
FirebaseArray *array = [[FirebaseArray alloc] initWithRef:firebaseRef];
```

#### Swift
```swift
let firebaseRef = FIRDatabase.database().reference()
let array = FirebaseArray(ref: firebaseRef)
```

### FirebaseDataSource

FirebaseDataSource acts as a generic data source by providing common information, such as the count of objects in the data source, and by requiring subclasses to implement FirebaseArrayDelegate methods as appropriate to the view. This class should never be instantiated, but should be subclassed when creating a specific adapter for a View. [FirebaseTableViewDataSource](https://github.com/firebase/FirebaseUI-iOS/blob/master/FirebaseUI/Implementation/FirebaseTableViewDataSource.m) and [FirebaseCollectionViewDataSource](https://github.com/firebase/FirebaseUI-iOS/blob/master/FirebaseUI/Implementation/FirebaseCollectionViewDataSource.m) are examples of this. FirebaseDataSource is essentially a wrapper around a FirebaseArray.
