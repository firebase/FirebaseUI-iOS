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

#import <Foundation/Foundation.h>

#import "FirebaseArrayDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@class FIRDatabaseQuery;
@class FIRDatabaseReference;
@class FIRDataSnapshot;

/**
 * FirebaseArray provides an array structure that is synchronized with a Firebase reference or
 * query. It is useful for building custom data structures or sources, and provides the base for
 * FirebaseDataSource.
 */
@interface FirebaseArray : NSObject

/**
 * The delegate object that array changes are surfaced to, which conforms to the
 * [FirebaseArrayDelegate Protocol](FirebaseArrayDelegate).
 */
@property(weak, nonatomic) id<FirebaseArrayDelegate> delegate;

/**
 * The query on a Firebase reference that provides data to populate the instance of FirebaseArray.
 */
@property(strong, nonatomic) FIRDatabaseQuery *query;

/**
 * The delegate object that array changes are surfaced to.
 */
@property(strong, nonatomic) NSMutableArray<FIRDataSnapshot *> * snapshots;

#pragma mark -
#pragma mark Initializer methods

/**
 * Intitalizes FirebaseArray with a standard Firebase reference.
 * @param ref The Firebase reference which provides data to FirebaseArray
 * @return The instance of FirebaseArray
 */
- (instancetype)initWithRef:(FIRDatabaseReference *)ref;

/**
 * Intitalizes FirebaseArray with a Firebase query (FIRDatabaseQuery).
 * @param query A query on a Firebase reference which provides filtered data to FirebaseArray
 * @return The instance of FirebaseArray
 */
- (instancetype)initWithQuery:(FIRDatabaseQuery *)query;

#pragma mark -
#pragma mark Public API methods

/**
 * Returns the count of objects in the FirebaseArray.
 * @return The count of objects in the FirebaseArray
 */
- (NSUInteger)count;

/**
 * Returns an object at a specific index in the FirebaseArray.
 * @param index The index of the item to retrieve
 * @return The object at the given index
 */
- (id)objectAtIndex:(NSUInteger)index;

/**
 * Returns a Firebase reference for an object at a specific index in the FirebaseArray.
 * @param index The index of the item to retrieve a reference for
 * @return A Firebase reference for the object at the given index
 */
- (FIRDatabaseReference *)refForIndex:(NSUInteger)index;

/**
 * Support for subscripting. Resolves to objectAtIndex:
 * @param index The index of the item to retrieve
 * @return The object at the given index
 */
- (id)objectAtIndexedSubscript:(NSUInteger)idx;

/**
 * Support for subscripting. This method is unused and trying to write directly to the
 * array using subscripting will cause an assertion.
 */
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx;

#pragma mark -
#pragma mark Private API methods

/**
 * Returns an index for a given object's key (that matches the object's key in the corresponding
 * Firebase reference).
 * @param key The key of the desired object
 * @return The index of the object for which the key matches or -1 if the key is null
 * @exception FirebaseArrayKeyNotFoundException Thrown when the desired key is not in the
 * FirebaseArray, likely indicating that the FirebaseArray is no longer being properly synchronized
 * with the Firebase database.
 */
- (NSUInteger)indexForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
