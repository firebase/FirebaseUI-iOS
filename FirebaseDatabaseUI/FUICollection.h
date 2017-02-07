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

@import Foundation;

@class FIRDatabaseReference, FIRDatabaseQuery, FIRDataSnapshot;
@protocol FUICollectionDelegate;

NS_ASSUME_NONNULL_BEGIN

/**
 * A protocol representing a collection of objects from Firebase Database.
 */
@protocol FUICollection <NSObject>

@property (nonatomic, readonly, copy) NSArray<FIRDataSnapshot *> *items;

@property (weak, nonatomic, nullable) id<FUICollectionDelegate> delegate;

/**
 * The number of objects in the collection.
 */
@property (nonatomic, readonly) NSUInteger count;

/**
 * The @c FIRDataSnapshot at the given index. May raise fatal errors
 * if the index is out of bounds.
 * @param index The index of a snapshot.
 */
- (FIRDataSnapshot *)snapshotAtIndex:(NSInteger)index;

/**
 * Calling this makes the array begin observing updates from its query.
 * Before this call is made the array is inert and doesn't do anything.
 */
- (void)observeQuery;

/**
 * Cancels all active observations. The array may be reused after this
 * is called by calling @c observeQuery again.
 */
- (void)invalidate;

@end

/**
 * A protocol to allow instances of FUIArray to raise events through a
 * delegate. Raises all Firebase events except FIRDataEventTypeValue.
 */
@protocol FUICollectionDelegate<NSObject>

@optional

/**
 * Called before any other events are sent.
 */
- (void)arrayDidBeginUpdates:(id<FUICollection>)collection;

/**
 * Called after all updates have finished.
 */
- (void)arrayDidEndUpdates:(id<FUICollection>)collection;

/**
 * Delegate method which is called whenever an object is added to an FUIArray.
 * On a FUIArray synchronized to a Firebase reference, this corresponds to an
 * @c FIRDataEventTypeChildAdded event being raised.
 * @param object The object added to the FUIArray
 * @param index The index the child was added at
 */
- (void)array:(id<FUICollection>)array didAddObject:(id)object atIndex:(NSUInteger)index;

/**
 * Delegate method which is called whenever an object is changed in an
 * FUIArray. On a FUIArray synchronized to a Firebase reference, this
 * corresponds to an @c FIRDataEventTypeChildChanged event being raised.
 * @param object The object that changed in the FUIArray
 * @param index The index the child was changed at
 */
- (void)array:(id<FUICollection>)array didChangeObject:(id)object atIndex:(NSUInteger)index;

/**
 * Delegate method which is called whenever an object is removed from an
 * FUIArray. On a FUIArray synchronized to a Firebase reference, this
 * corresponds to an @c FIRDataEventTypeChildRemoved event being raised.
 * @param object The object removed from the FUIArray
 * @param index The index the child was removed at
 */
- (void)array:(id<FUICollection>)array didRemoveObject:(id)object atIndex:(NSUInteger)index;

/**
 * Delegate method which is called whenever an object is moved within a
 * FUIArray. On a FUIArray synchronized to a Firebase reference, this
 * corresponds to an @c FIRDataEventTypeChildMoved event being raised.
 * @param object The object that has moved locations in the FUIArray
 * @param fromIndex The index the child is being moved from
 * @param toIndex The index the child is being moved to
 */
- (void)array:(id<FUICollection>)array didMoveObject:(id)object fromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;

/**
 * Delegate method which is called whenever the backing query is canceled.
 * @param error the error that was raised
 */
- (void)array:(id<FUICollection>)array queryCancelledWithError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
