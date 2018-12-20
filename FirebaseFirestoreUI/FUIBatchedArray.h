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

#import <FirebaseFirestore/FirebaseFirestore.h>

#import "FUISnapshotArrayDiff.h"

NS_ASSUME_NONNULL_BEGIN

@class FUIBatchedArray;

@protocol FUIBatchedArrayDelegate <NSObject>

/**
 * Called after any new data is received or the batched array's query did change.
 */
- (void)batchedArray:(FUIBatchedArray *)array
   didUpdateWithDiff:(FUISnapshotArrayDiff<FIRDocumentSnapshot *> *)diff;

/**
 * Called before any new data is received or the batched array's query will change.
 */
- (void)batchedArray:(FUIBatchedArray *)array
   willUpdateWithDiff:(FUISnapshotArrayDiff<FIRDocumentSnapshot *> *)diff;

/**
 * Called when the array's query raises an error.
 */
- (void)batchedArray:(FUIBatchedArray *)array queryDidFailWithError:(NSError *)error;

@end

@interface FUIBatchedArray : NSObject

/**
 * The query that this array should fetch data from. If this property is changed while
 * observing, the array will fetch updates from the new query, diff those with the contents of
 * the old query, and pass an update to its delegate.
 *
 * This class will try to diff the contents of the entire query on every value event, so
 * make sure to limit your queries to an appropriate size to avoid performance issues.
 */
@property (nonatomic, readwrite, strong) FIRQuery *query;

/**
 * The delegate that should receive events from this array instance.
 */
@property (nonatomic, readwrite, weak) id<FUIBatchedArrayDelegate> delegate;

/**
 * The number of items in the array.
 */
@property (nonatomic, readonly) NSInteger count;

/**
 * The snapshots currently held in the array.
 */
@property (nonatomic, readonly) NSArray<FIRDocumentSnapshot *> *items;

/**
 * Initializes a batched array with a query and delegate.
 */
- (instancetype)initWithQuery:(FIRQuery *)query
                     delegate:(nullable id<FUIBatchedArrayDelegate>)delegate NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

/**
 * Retrieves the snapshot at a given index. Raises an out of bounds error if the index is
 * out of bounds.
 */
- (FIRDocumentSnapshot *)objectAtIndex:(NSInteger)index;

/**
 * See objectAtIndex:
 */
- (FIRDocumentSnapshot *)objectAtIndexedSubscript:(NSInteger)index;

/**
 * Starts observing the array's query. Before this method is called no events will be sent
 * and the array will be empty.
 */
- (void)observeQuery;

/**
 * Stops observing the array's query. The array's contents will remain and `observeQuery` may 
 * be called again in the future to resume updates.
 */
- (void)stopObserving;

@end

NS_ASSUME_NONNULL_END
