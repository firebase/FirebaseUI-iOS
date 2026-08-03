# Firestore UI - UI Bindings for Cloud Firestore

Firestore UI provides a handful of classes that allow developers to easily bind
UI elements to Cloud Firestore queries, and to update their UI elements when
those queries change.

## API Overview

FUIFirestoreTableViewDataSource      | Binds a Firestore query to a table view.
FUIFirestoreCollectionViewDataSource | Binds a Firestore query to a collection view.
FUIBatchedArray                      | Maintains a local array containing the contents of a Firestore query.
FUISnapshotArrayDiff                 | Describes an array update in a manner friendly to table and collection views.

#### FUIFirestoreTableViewDataSource

`FUIFirestoreTableViewDataSource` is responsible for observing a Firestore query
and updating a UITableView as the query changes, suitable for single-section
table views dependent on a single query. The query can be re-assigned while
active, and the data source will generate an update from the two queries'
contents and pass it to its table view. To get started, use the
`bind(to:populateCell:)` method on `UITableView`. Usage is almost exactly the
same as it is in Firebase Database UI.

```swift
self.dataSource = tableView.bind(to: query) { tableView, indexPath, snapshot in
  // Dequeue cell
  let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
  /* populate cell */
  return cell
}
```

#### FUIFirestoreCollectionViewDataSource

Like its table view counterpart, `FUIFirestoreCollectionViewDataSource` keeps a
Firestore query in sync with a collection view instance, suitable for
single-section collection views dependent on a single query. To get started, use
the `bind(to:populateCell:)` method on `UICollectionView`.

```swift
self.dataSource = collectionView.bind(to: query) { collectionView, indexPath, snap in
  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reuseIdentifier", for: indexPath)
  /* populate cell */
  return cell
}
```

### Transforming and ordering data

Firestore UI binds the **results of a Firestore query** to a table or collection
view. It does not provide client-side `map` / `filter` / `sort` transforms on
those results (Realtime Database UI's `FUISortedArray` has no Firestore
counterpart). Shape data for display in one of these places instead:

1. **In the query** — filter, order, and limit with Firestore query APIs before
   binding. Prefer this for anything that affects which documents appear or in
   what order.
2. **In `populateCell`** — map fields onto cell UI when dequeuing. Prefer this
   for presentation-only changes (labels, formatting, hiding empty fields).

#### Query-side ordering and limits

```swift
// Newest-first list
let query = Firestore.firestore()
  .collection("posts")
  .order(by: "createdAt", descending: true)
  .limit(to: 50)

self.dataSource = tableView.bind(to: query) { tableView, indexPath, snapshot in
  let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier",
                                           for: indexPath)
  let data = snapshot.data()
  cell.textLabel?.text = data?["title"] as? String
  return cell
}
```

For a chat-style feed (latest N messages, oldest → newest in the list), use
`limit(toLast:)` with ascending order:

```swift
let query = Firestore.firestore()
  .collection("rooms").document(roomId).collection("messages")
  .order(by: "timestamp")
  .limit(toLast: 30)

self.dataSource = tableView.bind(to: query) { tableView, indexPath, snapshot in
  let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier",
                                           for: indexPath)
  /* populate cell */
  return cell
}
```

Keep queries bounded. `FUIBatchedArray` diffs the full result set on updates and
on query changes, so unbounded listeners will hurt performance.

#### FUIBatchedArray

`FUIBatchedArray` powers all of the updating logic in the data source classes
by generating diffs from the document change data in Firestore query snapshot
updates. The query assigned to a batched array is mutable, and may be changed
while the array is observing its query. In this event, the array will compute
an update by diffing the contents of the old and new query and pass an update
to its delegate. This operation is relatively expensive, so try to avoid diffing
large or unbounded queries.

If you're creating a more complex UI, chances are you'll have to use
`FUIBatchedArray` directly.

```swift
let array = FUIBatchedArray(query: query, delegate: self)
array.observeQuery()
```

#### FUISnapshotArrayDiff

This class and its helper classes are responsible for the diffing logic in
FirestoreUI. You should never have to use this directly, though all of the
operations here are pure and most have no dependencies on Firestore, so if
you need to diff arbitrary data you can use the functions provided here.
