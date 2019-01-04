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

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@class FIRDocumentChange, FIRDocumentSnapshot;

/**
 * Constructs a diff from two arrays. Initialization is O(m * n), where m and n are the lengths
 * of the input arrays. Construction is expensive, and diffs are not cached.
 */
@interface FUISnapshotArrayDiff : NSObject

/** The initial array. */
@property (nonatomic, readonly) NSArray<FIRDocumentSnapshot *> *initial;

/** The resulting array. */
@property (nonatomic, readonly) NSArray<FIRDocumentSnapshot *> *result;

/** An array of indexes of deleted items relative to the initial array. */
@property (nonatomic, readonly) NSArray<NSNumber *> *deletedIndexes;

/** An array of objects deleted from the initial array. */
@property (nonatomic, readonly) NSArray<FIRDocumentSnapshot *> *deletedObjects;

/** An array of the initial indexes of moved items. */
@property (nonatomic, readonly) NSArray<NSNumber *> *movedInitialIndexes;

/** An array of the final indexes of moved items. */
@property (nonatomic, readonly) NSArray<NSNumber *> *movedResultIndexes;

/** An array of objects that were moved. */
@property (nonatomic, readonly) NSArray<FIRDocumentSnapshot *> *movedObjects;

/** An array of indexes of objects that were changed. */
@property (nonatomic, readonly) NSArray<NSNumber *> *changedIndexes;

/** An array of the resulting objects that were changed. */
@property (nonatomic, readonly) NSArray<FIRDocumentSnapshot *> *changedObjects;

/** An array of indexes of objects that were inserted, relative to the final array. */
@property (nonatomic, readonly) NSArray<NSNumber *> *insertedIndexes;

/** An array of inserted objects. */
@property (nonatomic, readonly) NSArray<FIRDocumentSnapshot *> *insertedObjects;

/**
 * Creates a non-minimal diff between two arrays. This operation is relatively inexpensive;
 * O(n + m) for arrays of length n and m.
 */
- (instancetype)initWithInitialArray:(NSArray<FIRDocumentSnapshot *> *)initialArray
                         resultArray:(NSArray<FIRDocumentSnapshot *> *)resultArray;

/**
 * Creates a diff between two arrays, using the document changes array to speed up
 * performance.
 */
- (instancetype)initWithInitialArray:(NSArray<FIRDocumentSnapshot *> *)initial
                         resultArray:(NSArray<FIRDocumentSnapshot *> *)result
                     documentChanges:(NSArray<FIRDocumentChange *> *)documentChanges;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
