// clang-format off

//
//  Copyright (c) 2016 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

// clang-format on

#import "FUIArray.h"

NS_ASSUME_NONNULL_BEGIN

@class FUIIndexArray;

/**
 * A protocol to allow instances of FUIIndexArray to raise events through a
 * delegate. Raises all Firebase events except @c FIRDataEventTypeValue.
 */
@protocol FUIIndexArrayDelegate <NSObject>

@optional

/**
 * Delegate method called when the database reference at an index has
 * finished loading its contents.
 * @param array The array containing the reference.
 * @param ref The reference that was loaded.
 * @param object The database reference's contents.
 * @param index The index of the reference that was loaded.
 */
- (void)array:(FUIIndexArray *)array
    reference:(FIRDatabaseReference *)ref
didLoadObject:(FIRDataSnapshot *)object
      atIndex:(NSUInteger)index;

/**
 * Delegate method called when the database reference at an index has 
 * failed to load contents.
 * @param array The array containing the reference.
 * @param ref The reference that failed to load.
 * @param index The index in the array of the reference that failed to load.
 * @param error The error that occurred.
 */
- (void)array:(FUIIndexArray *)array
    reference:(FIRDatabaseReference *)ref
      atIndex:(NSUInteger)index
didFailLoadWithError:(NSError *)error;

/**
 * Delegate method which is called whenever an object is added to a
 * FirebaseArray. On a FirebaseArray synchronized to a Firebase reference, 
 * this corresponds to a @c FIRDataEventTypeChildAdded event being raised.
 * @param ref The database reference added to the array
 * @param index The index the reference was added at
 */
- (void)array:(FUIIndexArray *)array didAddReference:(FIRDatabaseReference *)ref atIndex:(NSUInteger)index;

/**
 * Delegate method which is called whenever an object is changed in a
 * FirebaseArray. On a FirebaseArray synchronized to a Firebase reference, 
 * this corresponds to a @c FIRDataEventTypeChildChanged event being raised.
 * @param ref The database reference that changed in the array
 * @param index The index the reference was changed at
 */
- (void)array:(FUIIndexArray *)array didChangeReference:(FIRDatabaseReference *)ref atIndex:(NSUInteger)index;

/**
 * Delegate method which is called whenever an object is removed from a
 * FirebaseArray. On a FirebaseArray synchronized to a Firebase reference, 
 * this corresponds to a @c FIRDataEventTypeChildRemoved event being raised.
 * @param ref The database reference removed from the array
 * @param index The index the reference was removed at
 */
- (void)array:(FUIIndexArray *)array didRemoveReference:(FIRDatabaseReference *)ref atIndex:(NSUInteger)index;

/**
 * Delegate method which is called whenever an object is moved within a
 * FirebaseArray. On a FirebaseArray synchronized to a Firebase reference, 
 * this corresponds to a @c FIRDataEventTypeChildMoved event being raised.
 * @param ref The database reference that has moved locations
 * @param fromIndex The index the reference is being moved from
 * @param toIndex The index the reference is being moved to
 */
- (void)array:(FUIIndexArray *)array didMoveReference:(FIRDatabaseReference *)ref fromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;

/**
 * Delegate method which is called whenever the backing query is canceled. This error is fatal
 * and the index array will become unusable afterward, so please handle it appropriately
 * (i.e. by displaying a modal error explaining why there's no content).
 * @param error the error that was raised
 */
- (void)array:(FUIIndexArray *)array queryCancelledWithError:(NSError *)error;

@end

/**
 * A FUIIndexArray instance uses a query's contents to query children of
 * a separate database reference, which is useful for displaying an indexed list
 * of data as described in https://firebase.google.com/docs/database/ios/structure-data
 */
@interface FUIIndexArray : NSObject

/**
 * An immutable copy of the loaded contents in the array. Returns an
 * empty array if no contents have loaded yet.
 */
@property(nonatomic, copy, readonly) NSArray<FIRDataSnapshot *> *items;

/**
 * An immutable copy of the loaded indexes in the array. Returns an empty
 * array if no indexes have loaded.
 */
@property(nonatomic, copy, readonly) NSArray<FIRDataSnapshot *> *indexes;

/**
 * The delegate that this array should forward events to.
 */
@property(nonatomic, weak) id<FUIIndexArrayDelegate> delegate;

/**
 * Returns the number of items in the array.
 */
@property(nonatomic, readonly) NSUInteger count;

- (instancetype)init NS_UNAVAILABLE;

/**
 * Initializes a FUIIndexArray with an index query and a data query.
 * The array expects the keys of the children of the index query to match exactly children
 * of the data query.
 * @param index A Firebase database query whose childrens' keys are all children 
 *   of the data query.
 * @param data  A Firebase database reference whose children will be fetched and used
 *   to populate the array's contents according to the index query.
 * @param delegate The delegate that events should be forwarded to.
 */
- (instancetype)initWithIndex:(id<FUIDataObservable>)index
                         data:(id<FUIDataObservable>)data
                     delegate:(nullable id<FUIIndexArrayDelegate>)delegate NS_DESIGNATED_INITIALIZER;

/**
 * Initializes a FUIIndexArray with an index query and a data query.
 * The array expects the keys of the children of the index query to be children
 * of the data query.
 * @param index A Firebase database query whose childrens' keys are all children
 *   of the data query.
 * @param data  A Firebase database reference whose children will be fetched and used
 *   to populate the array's contents according to the index query.
 */
- (instancetype)initWithIndex:(id<FUIDataObservable>)index
                         data:(id<FUIDataObservable>)data;

/**
 * Returns the snapshot at the given index, if it has loaded.
 * Raises a fatal error if the index is out of bounds.
 * @param index The index of the requested snapshot.
 * @return A snapshot, or nil if one has not yet been loaded.
 */
- (nullable FIRDataSnapshot *)objectAtIndex:(NSUInteger)index;

/**
 * Starts observing the index array's listeners. The indexed array will pass updates to its delegate
 * until the `invalidate` method is called.
 */
- (void)observeQuery;

/**
 * Removes all observers from all queries managed by this array and renders this array
 * unusable. Initialize a new array instead of reusing this array.
 */
- (void)invalidate;

@end

NS_ASSUME_NONNULL_END
