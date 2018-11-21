# FirebaseUI Database — UI Bindings for the Firebase Realtime Database

FirebaseUI Database allows you to quickly connect common UI elements to the [Firebase Realtime Database](https://firebase.google.com/docs/database?utm_source=firebaseui-ios) for data storage, allowing views to be updated in realtime as they change, and providing simple interfaces for common tasks like displaying lists or collections of items.

## FirebaseUI Database
Provides core data binding capabilities as well as specific data sources for lists of data.

Class                            | Description
-------------------------------- | --------------------------------
FUITableViewDataSource           | Data source to bind a Firebase query to a UITableView
FUICollectionViewDataSource      | Data source to bind a Firebase query to a UICollectionView
FUIIndexCollectionViewDataSource | Data source to populate a collection view with indexed data from Firebase DB.
FUIIndexTableViewDataSource      | Data source to populate a table view with indexed data from Firebase DB.
FUIArray                         | Keeps an array synchronized to a Firebase query
FUISortedArray                   | A synchronized array that automatically sorts its contents.
FUIIndexArray                    | Keeps an array synchronized to indexed data from two Firebase references.

For a more in-depth explanation of each of the above, check the usage instructions below.

## API Overview
### FUITableViewDataSource

`FUITableViewDataSource` implements the `UITableViewDataSource` protocol to automatically use Firebase as a data source for your `UITableView`.

#### Swift
```swift
self.dataSource = self.tableView.bind(to: query) { tableView, indexPath, snapshot in
  // Dequeue cell
  let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
  /* populate cell */
  return cell
}
```

#### Objective-C

```objc
self.dataSource = [self.tableView bindToQuery:query
                                 populateCell:^UITableViewCell *(UITableView *tableView,
                                                                 NSIndexPath *indexPath,
                                                                 FIRDataSnapshot *snap) {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"
                                                          forIndexPath:indexPath];
  /* populate cell */
  return cell;
}];
```

### FUICollectionViewDataSource

`FUICollectionViewDataSource` implements the `UICollectionViewDataSource` protocol to automatically use Firebase as a data source for your `UICollectionView`.

#### Swift
```swift
self.dataSource = self.collectionView.bind(to: self.firebaseRef) { collectionView, indexPath, snap in
  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reuseIdentifier", for: indexPath)
  /* populate cell */
  return cell
}
```

#### Objective-C

```objective-c
self.firebaseRef = [[FIRDatabase database] reference];
self.dataSource = [self.collectionView bindToQuery:self.firebaseRef
                                      populateCell:^UICollectionViewCell *(UICollectionView *collectionView,
                                                                           NSIndexPath *indexPath,
                                                                           FIRDataSnapshot *object) {
  UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"reuseIdentfier"
                                                                    forIndexPath:indexPath];
  /* populate cell */
  return cell;
}];
```

### Using the Default Table/Collection View Cell

You can use the default `UITableViewCell` or `UICollectionViewCell` implementations to get up and running quickly. For `UITableViewCell`s, this allows for the `cell.textLabel` and the `cell.detailTextLabel` to be used directly out of the box. For `UICollectionViewCell`s, you will have to add subviews to the contentView in order for them to be useful.

#### Swift
```swift
self.dataSource = self.tableView.bind(to: firebaseRef) { tableView, indexPath, snap in
  let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
  // Populate cell as you see fit, like as below
  cell.textLabel?.text = snap.key
  return cell
}
```

```swift
self.dataSource = self.collectionView.bind(to: firebaseRef) { collectionView, indexPath, snap in
  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reuseIdentifier", for: indexPath)
  // Populate cell as you see fit
  cell.contentView.accessibilityLabel = "A cell"
  return cell
}
```

#### Objective-C
```objective-c
self.dataSource = [self.tableView bindToQuery:self.firebaseRef
                                 populateCell:^UITableViewCell *(UITableView *tableView,
                                                                 NSIndexPath *indexPath,
                                                                 FIRDataSnapshot *snap) {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"
                                                          forIndexPath:indexPath];
  // Populate cell as you see fit, like as below
  cell.textLabel.text = snap.key;
  return cell;
}];
```

```objective-c
self.dataSource = [self.collectionView bindToQuery:self.firebaseRef
                                      populateCell:^UICollectionViewCell *(UICollectionView *collectionView,
                                                                      NSIndexPath *indexPath,
                                                                      FIRDataSnapshot *snap) {
  UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"reuseIdentifier"
                                                                    forIndexPath:indexPath];
  // Populate cell as you see fit
  cell.contentView.accessibilityLabel = @"A cell";
  return cell;
}];
```

## Understanding FirebaseUI Database's Internals

FirebaseUI has several building blocks that developers should understand before building additional functionality on top of it, including a synchronized array `FUIArray` and collection protocol `FUICollection` which `FUITableViewDataSource` and `FUICollectionViewDataSource` use to drive UI updates.

### FUIArray and the FUICollectionDelegate Protocol

`FUIArray` is synchronized array connecting a Firebase `FIRDatabaseReference` with an array. It surfaces Firebase events through the `FUICollectionDelegate` Protocol. If you're building a multiple-section UI, you'll have to use this class directly instead of using one of the provided data sources.

#### Swift
```swift
let firebaseRef = Database.database().reference()
let array = FUIArray(query: firebaseRef)
```

#### Objective-C
```objective-c
FIRDatabaseReference *firebaseRef = [[FIRDatabase database] reference];
FUIArray *array = [[FUIArray alloc] initWithQuery:firebaseRef];
```

`FUIArray` can be subclassed to provide more complex behaviors like client-side sorting. Take a look at `FUISortedArray` for an example on how to do this.
