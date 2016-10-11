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

#import "FirebaseArray.h"

NS_ASSUME_NONNULL_BEGIN

@class FirebaseIndexArray;

/**
 * A protocol to allow instances of FirebaseArray to raise events through a
 * delegate. Raises all
 * Firebase events except FIRDataEventTypeValue.
 */
@protocol FirebaseIndexArrayDelegate<NSObject>

@optional

/**
 * Delegate method called when the database reference at an index has 
 * finished loading its contents.
 * @param array The array containing the reference.
 * @param ref The reference that was loaded.
 * @param object The database reference's contents.
 * @param index The index of the reference that was loaded.
 */
- (void)array:(FirebaseIndexArray *)array
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
- (void)array:(FirebaseIndexArray *)array
    reference:(FIRDatabaseReference *)ref
      atIndex:(NSUInteger)index
didFailLoadWithError:(NSError *)error;

/**
 * Delegate method which is called whenever an object is added to a
 * FirebaseArray. On a
 * FirebaseArray synchronized to a Firebase reference, this corresponds to an
 * [FIRDataEventTypeChildAdded](https://www.firebase.com/docs/ios/guide/retrieving-data.html#section-event-types)
 * event being raised.
 * @param ref The database reference added to the array
 * @param index The index the reference was added at
 */
- (void)array:(FirebaseIndexArray *)array didAddReference:(FIRDatabaseReference *)ref atIndex:(NSUInteger)index;

/**
 * Delegate method which is called whenever an object is chinged in a
 * FirebaseArray. On a
 * FirebaseArray synchronized to a Firebase reference, this corresponds to an
 * [FIRDataEventTypeChildChanged](https://www.firebase.com/docs/ios/guide/retrieving-data.html#section-event-types)
 * event being raised.
 * @param object The database reference that changed in the array
 * @param index The index the reference was changed at
 */
- (void)array:(FirebaseIndexArray *)array didChangeReference:(FIRDatabaseReference *)ref atIndex:(NSUInteger)index;

/**
 * Delegate method which is called whenever an object is removed from a
 * FirebaseArray. On a
 * FirebaseArray synchronized to a Firebase reference, this corresponds to an
 * [FIRDataEventTypeChildRemoved](https://www.firebase.com/docs/ios/guide/retrieving-data.html#section-event-types)
 * event being raised.
 * @param object The database reference removed from the array
 * @param index The index the reference was removed at
 */
- (void)array:(FirebaseIndexArray *)array didRemoveReference:(FIRDatabaseReference *)ref atIndex:(NSUInteger)index;

/**
 * Delegate method which is called whenever an object is moved within a
 * FirebaseArray. On a
 * FirebaseArray synchronized to a Firebase reference, this corresponds to an
 * [FIRDataEventTypeChildMoved](https://www.firebase.com/docs/ios/guide/retrieving-data.html#section-event-types)
 * event being raised.
 * @param object The database reference that has moved locations
 * @param fromIndex The index the reference is being moved from
 * @param toIndex The index the reference is being moved to
 */
- (void)array:(FirebaseIndexArray *)array didMoveReference:(FIRDatabaseReference *)ref fromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;

/**
 * Delegate method which is called whenever the backing query is canceled. This error is fatal
 * and the index array will become unusable afterward, so please handle it appropriately.
 * @param error the error that was raised
 */
- (void)array:(FirebaseIndexArray *)array queryCancelledWithError:(NSError *)error;

@end

@interface FirebaseIndexArray : NSObject

@property(nonatomic, copy, readonly) NSArray<FIRDataSnapshot *> *items;

@property(nonatomic, weak) id<FirebaseIndexArrayDelegate> delegate;

- (instancetype)init NS_UNAVAILABLE;

/**
 * Initializes a FirebaseIndexArray with an index query and a data query.
 * The array expects the keys of the children of the index query to be children
 * of the data query.
 * @param index A Firebase database query whose childrens' keys are all children 
 *   of the data query.
 * @param data  A Firebase database reference whose children will be fetched and used
 *   to populate the array's contents according to the index query.
 * @param delegate The delegate that events should be forwarded to.
 */
- (instancetype)initWithIndex:(id<FIRDataObservable>)index
                         data:(id<FIRDataObservable>)data
                     delegate:(nullable id<FirebaseIndexArrayDelegate>)delegate NS_DESIGNATED_INITIALIZER;

/**
 * Initializes a FirebaseIndexArray with an index query and a data query.
 * The array expects the keys of the children of the index query to be children
 * of the data query.
 * @param index A Firebase database query whose childrens' keys are all children
 *   of the data query.
 * @param data  A Firebase database reference whose children will be fetched and used
 *   to populate the array's contents according to the index query.
 */
- (instancetype)initWithIndex:(id<FIRDataObservable>)index
                         data:(id<FIRDataObservable>)data;

/**
 * Returns the snapshot at the given index, if it has loaded.
 * @param index The index of the requested snapshot.
 * @return A snapshot, or nil if one has not yet been loaded.
 */
- (nullable FIRDataSnapshot *)objectAtIndex:(NSUInteger)index;

/**
 * Removes all observers from all queries managed by this array and renders this array
 * unusable.
 */
- (void)invalidate;

@end

NS_ASSUME_NONNULL_END
