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

#import <FirebaseDatabase/FirebaseDatabase.h>

#import "FUICollection.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FUIDataObservable <NSObject>
@required

- (FIRDatabaseHandle)observeEventType:(FIRDataEventType)eventType
       andPreviousSiblingKeyWithBlock:(void (^)(FIRDataSnapshot *snapshot, NSString *__nullable prevKey))block
                      withCancelBlock:(nullable void (^)(NSError* error))cancelBlock;

- (void)removeObserverWithHandle:(FIRDatabaseHandle)handle;

- (id<FUIDataObservable>)child:(NSString *)path;

@end

@interface FIRDatabaseQuery (FUIDataObservable) <FUIDataObservable>
@end

/**
 * FUIArray provides an array structure that is synchronized with a Firebase reference or
 * query. It is useful for building custom data structures or sources, and provides the base for
 * FirebaseDataSource. FUIArray maintains a large amount of internal state, and most of its methods
 * are not thread-safe.
 */
@interface FUIArray : NSObject <FUICollection>

/**
 * The delegate object that array changes are surfaced to, which conforms to the
 * @c FUICollectionDelegate protocol.
 */
@property (weak, nonatomic, nullable) id<FUICollectionDelegate> delegate;

/**
 * The query on a Firebase reference that provides data to populate the array.
 */
@property (strong, nonatomic) id<FUIDataObservable> query;

/**
 * The number of objects in the array.
 */
@property (nonatomic, readonly) NSUInteger count;

/**
 * The items currently in the array.
 */
@property (nonatomic, readonly, copy) NSArray *items;

#pragma mark - Initializer methods

/**
 * Initalizes an FUIArray with a Firebase query (FIRDatabaseQuery) or database reference
 * (FIRDatabaseReference).
 * @param query    A query or Firebase database reference
 * @param delegate An object conforming to FirebaseArrayDelegate that should receive delegate messages.
 * @return A FirebaseArray instance
 */
- (instancetype)initWithQuery:(id<FUIDataObservable>)query
                     delegate:(nullable id<FUICollectionDelegate>)delegate NS_DESIGNATED_INITIALIZER;

/**
 * Initalizes FirebaseArray with a Firebase query (FIRDatabaseQuery) or database reference
 * (FIRDatabaseReference).
 * @param query A query or Firebase database reference
 * @return A FirebaseArray instance
 */
- (instancetype)initWithQuery:(id<FUIDataObservable>)query;

/**
 * See `initWithQuery:`
 */
+ (instancetype)arrayWithQuery:(id<FUIDataObservable>)query;

- (instancetype)init NS_UNAVAILABLE;

#pragma mark - Public API methods

/**
 * Returns an object at a specific index in the array.
 * @param index The index of the item to retrieve
 * @return The snapshot at the given index
 */
- (FIRDataSnapshot *)snapshotAtIndex:(NSInteger)index;

/**
 * Returns a Firebase reference for an object at a specific index in the array.
 * @param index The index of the item to retrieve a reference for
 * @return A Firebase reference for the object at the given index
 */
- (FIRDatabaseReference *)refForIndex:(NSUInteger)index;

/**
 * Support for subscripting. Resolves to objectAtIndex:
 * @param idx The index of the item to retrieve
 * @return The object at the given index
 */
- (id)objectAtIndexedSubscript:(NSUInteger)idx;

/**
 * Support for subscripting. This method is unused and trying to write directly to the
 * array using subscripting will cause an assertion failure.
 */
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx NS_UNAVAILABLE;

/**
 * Returns an index for a given object's key (that matches the object's key in the corresponding
 * Firebase reference).
 * @param key The key of the desired object
 * @return The index of the object for which the key matches or NSNotFound if the key is not found
 * @exception NSInvalidArgumentException Thrown when the `key` parameter is `nil`.
 */
- (NSUInteger)indexForKey:(NSString *)key;

/**
 * Called when the Firebase query sends a FIRDataEventTypeChildAdded event. Override this
 * to provide custom insertion logic. Don't call this method directly.
 * @param snap The snapshot that was inserted.
 * @param previous The key of the sibling preceding the inserted snapshot.
 */
- (void)insertSnapshot:(FIRDataSnapshot *)snap withPreviousChildKey:(nullable NSString *)previous;

/**
 * Called when the Firebase query sends a FIRDataEventTypeChildRemoved event. Override this
 * to provide custom removal logic. Don't call this method directly.
 * @param snap The snapshot that was removed.
 * @param previous The key of the sibling preceding the removed snapshot.
 */
- (void)removeSnapshot:(FIRDataSnapshot *)snap withPreviousChildKey:(nullable NSString *)previous;

/**
 * Called when the Firebase query sends a FIRDataEventTypeChildChanged event. Override this
 * to provide custom on change logic. Don't call this method directly.
 * @param snap The snapshot whose value was changed.
 * @param previous The key of the sibling preceding the changed snapshot.
 */
- (void)changeSnapshot:(FIRDataSnapshot *)snap withPreviousChildKey:(nullable NSString *)previous;

/**
 * Called when the Firebase query sends a FIRDataEventTypeChildMoved event. Override this
 * to provide custom move logic. Don't call this method directly.
 * @param snap The snapshot that was moved.
 * @param previous The key of the sibling preceding the moved snapshot at its new location.
 */
- (void)moveSnapshot:(FIRDataSnapshot *)snap withPreviousChildKey:(nullable NSString *)previous;

@end

NS_ASSUME_NONNULL_END
