# FirebaseUI/Database for iOS — UI Bindings for the Firebase Realtime Database

FirebaseUI/Database allows you to quickly connect common UI elements to the [Firebase Realtime Database](https://firebase.google.com/docs/database?utm_source=firebaseui-ios) for data storage, allowing views to be updated in realtime as they change, and providing simple interfaces for common tasks like displaying lists or collections of items.

## FirebaseUI Database
Provides core data binding capabilities as well as specific datasources for lists of data. Skip to the [Core API overview](https://github.com/firebase/firebaseui-ios#firebaseui-core-api) for more information.

Class                            | Description
-------------------------------- | --------------------------------
FUITableViewDataSource           | Data source to bind a Firebase query to a UITableView
FUICollectionViewDataSource      | Data source to bind a Firebase query to a UICollectionView
FUIIndexCollectionViewDataSource | Data source to populate a collection view with indexed data from Firebase DB.
FUIIndexTableViewDataSource      | Data source to populate a table view with indexed data from Firebase DB.
FUIArray                         | Keeps an array synchronized to a Firebase query
FUIIndexArray                    | Keeps an array synchronized to indexed data from two Firebase references.
FUIDataSource                    | Generic superclass to create a custom data source

For a more in-depth explanation of each of the above, check the usage instructions below or read the [docs](https://firebaseui.firebaseapp.com/docs/ios/index.html).

## FirebaseUI Database API
### FUITableViewDataSource

`FUITableViewDataSource` implements the `UITableViewDataSource` protocol to automatically use Firebase as a data source for your `UITableView`.

#### Objective-C
```objc
// YourViewController.h

@property (strong, nonatomic) FIRDatabaseReference *firebaseRef;
@property (strong, nonatomic) FUITableViewDataSource *dataSource;
```

```objective-c
// YourViewController.m
self.dataSource = [self.tableView bindToQuery:self.firebaseRef
                                 populateCell:^UITableViewCell *(UITableView *tableView,
                                                                 NSIndexPath *indexPath,
                                                                 FIRDataSnapshot *object) {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"
                                                          forIndexPath:indexPath];
  /* populate cell */
  return cell;
}];
```

#### Swift
```swift
// YourViewController.swift

let firebaseRef = FIRDatabase.database().reference()
var dataSource: FUITableViewDataSource!

self.dataSource = self.tableView.bind(to: self.firebaseRef) { tableView, indexPath, snapshot in
  // Dequeue cell
  let cell = tableView.dequeueReusableCell(withReuseIdentifier: "reuseIdentifier", for: indexPath)
  /* populate cell */
  return cell
}
```

### FUICollectionViewDataSource

`FUICollectionViewDataSource` implements the `UICollectionViewDataSource` protocol to automatically use Firebase as a data source for your `UICollectionView`.

#### Objective-C
```objective-c
// YourViewController.h

@property (strong, nonatomic) FIRDatabaseReference *firebaseRef;
@property (strong, nonatomic) FUICollectionViewDataSource *dataSource;
```

```objective-c
// YourViewController.m

self.firebaseRef = [[FIRDatabase database] reference];
self.dataSource = [self.collectionView bindToQuery:self.firebaseRef
                                      populateCell:^UICollectionViewCell *(UICollectionView *collectionView,
                                                                           NSIndexPath *indexPath,
                                                                           FIRDataSnapshot *object) {
  UICollectionViewCell *cell = [collectionView dequeueReusableCellWithIdentifier:@"reuseIdentfier"
                                                                    forIndexPath:indexPath];
  /* populate cell */
  return cell;
}];
```

#### Swift
```swift
// YourViewController.swift

self.dataSource = self.collectionView.bind(to: self.firebaseRef) { collectionView, indexPath, snap in
  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reuseIdentifier", for: indexPath)
  /* populate cell */
  return cell
}
```

## Customizing your UITableView or UICollectionView

You can use `FUITableViewDataSource` or `FUICollectionViewDataSource` in several ways to create custom UITableViews or UICollectionViews. For more information on how to create custom UITableViews, check out the following tutorial on [TutsPlus](http://code.tutsplus.com/tutorials/ios-sdk-crafting-custom-uitableview-cells--mobile-15702). For more information on how to create custom UICollectionViews, particularly how to implement a UICollectionViewLayout, check out the following tutorial on Ray Wenderlich in [Objective-C](http://www.raywenderlich.com/22324/beginning-uicollectionview-in-ios-6-part-12) and [Swift](http://www.raywenderlich.com/78550/beginning-ios-collection-views-swift-part-1).

### Using the Default UI*ViewCell Implementation

You can use the default `UITableViewCell` or `UICollectionViewCell` implementations to get up and running quickly. For `UITableViewCell`s, this allows for the `cell.textLabel` and the `cell.detailTextLabel` to be used directly out of the box. For `UICollectionViewCell`s, you will have to add subviews to the contentView in order for it to be useful.

#### Objective-C UITableView and UICollectionView with Default UI*ViewCell
```objective-c
self.dataSource = [self.tableView bindToQuery:firebaseRef
                                 populateCell:^UITableViewCell *(UITableView *tableView,
                                                                 NSIndexPath *indexPath,
                                                                 FIRDataSnapshot *object) {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"
                                                          forIndexPath:indexPath];
  // Populate cell as you see fit, like as below
  cell.textLabel.text = snap.key;
  return cell;
}];
```

```objective-c
self.dataSource = [self.collectionView bindToQuery:firebaseRef
                                      populateCell:^UITableViewCell *(UICollectionView *collectionView,
                                                                      NSIndexPath *indexPath,
                                                                      FIRDataSnapshot *object) {
  UICollectionViewCell *cell = [collectionView dequeueReusableCellWithIdentifier:@"reuseIdentifier"
                                                                    forIndexPath:indexPath];
  // Populate cell as you see fit by adding subviews as appropriate
  cell.contentView.addSubview(customView)
  return cell;
}];
```

#### Swift UITableView and UICollectionView with Default UI*ViewCell
```swift
self.dataSource = self.tableView.bind(to: firebaseRef) { tableView, indexPath, snap in
  let cell = tableView.dequeueReusableCell(withReuseIdentifier: "reuseIdentifier", for: indexPath)
  // Populate cell as you see fit, like as below
  cell.textLabel.text = snap.key
  return cell
}
```

```swift
self.dataSource = self.collectionView.bind(to: firebaseRef) { collectionView, indexPath, snap in
  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reuseIdentifier", for: indexPath)
  // Populate cell as you see fit by adding subviews as appropriate
  cell.contentView.addSubview(customView)
  return cell
}
```

## Understanding FirebaseUI Core's Internals

FirebaseUI has several building blocks that developers should understand before building additional functionality on top of FirebaseUI, including a synchronized array `FUIArray` and a generic data source superclass `FUIDataSource` from which `FUITableViewDataSource` and `FUICollectionViewDataSource` or other custom data source classes subclass.

### FUIArray and the FUIArrayDelegate Protocol

`FUIArray` is synchronized array connecting a Firebase Ref with an array. It surfaces Firebase events through the FUIArrayDelegate Protocol. It is generally recommended that developers not directly access `FUIArray` without routing it through a custom data source, though if this is desired, check out `FUIDataSource` below.

#### Objective-C
```objective-c
FIRDatabaseReference *firebaseRef = [[FIRDatabase database] reference];
FUIArray *array = [[FUIArray alloc] initWithRef:firebaseRef];
```

#### Swift
```swift
let firebaseRef = FIRDatabase.database().reference()
let array = FUIArray(ref: firebaseRef)
```

### FUIDataSource

FUIDataSource acts as a generic data source by providing common information, such as the count of objects in the data source, and by requiring subclasses to implement FUIArrayDelegate methods as appropriate to the view. This class should never be instantiated, but should be subclassed when creating a specific adapter for a View. [FUITableViewDataSource](https://github.com/firebase/FirebaseUI-iOS/blob/master/FirebaseUI/Implementation/FUITableViewDataSource.m) and [FUICollectionViewDataSource](https://github.com/firebase/FirebaseUI-iOS/blob/master/FirebaseUI/Implementation/FUICollectionViewDataSource.m) are examples of this. FUIDataSource is essentially a wrapper around a FUIArray.
