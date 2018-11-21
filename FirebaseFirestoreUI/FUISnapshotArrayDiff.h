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

/**
 * A lightweight class maintaining a view of a slice of an array without ever copying the
 * array's contents (except on init, and only if the array is mutable). Since the cost
 * to instantiating a new slice is so low, the slices themselves are immutable.
 */
@interface FUIArraySlice<__covariant ObjectType> : NSObject

/**
 * The index of the first element of the array slice. Inclusive.
 */
@property (nonatomic, readonly) NSInteger startIndex;

/**
 * The index following the last element of the array slice. Exclusive.
 */
@property (nonatomic, readonly) NSInteger endIndex;

/**
 * The number of elements in the array slice.
 */
@property (nonatomic, readonly) NSInteger count;

/**
 * The array storage backing the array slice instance.
 */
@property (nonatomic, readonly) NSArray<ObjectType> *backingArray;

/**
 * Initializes an array slice from an array, a start index, and a length.
 */
- (instancetype)initWithArray:(NSArray<ObjectType> *)array
                   startIndex:(NSInteger)start
                       length:(NSInteger)length NS_DESIGNATED_INITIALIZER;

/**
 * Initializes an array slice from an array, a start index (inclusive), and an
 * end index (exclusive).
 */
- (instancetype)initWithArray:(NSArray<ObjectType> *)array
                   startIndex:(NSInteger)start
                     endIndex:(NSInteger)end;

/**
 * Initializes an array slice encompassing the entire array argument.
 */
- (instancetype)initWithArray:(NSArray<ObjectType> *)array;

/**
 * Initializes an empty array slice with an empty backing array.
 */
- (instancetype)init;

/**
 * The object from the backing array in the array slice. Throws an invalid argument exception
 * if the index is out of bounds.
 */
- (ObjectType)objectAtIndex:(NSInteger)index;

- (ObjectType)objectAtIndexedSubscript:(NSInteger)index;

/**
 * Returns a subslice from the specified index to the end of the receiver.
 */
- (FUIArraySlice *)suffixFromIndex:(NSInteger)index;

@end


/**
 * An immutable unordered pair class that returns equivalent iff two pairs contain the same
 * elements, regardless of order.
 */
@interface FUIUnorderedPair<__covariant ObjectType> : NSObject <NSCopying>

@property (nonatomic, readonly) ObjectType left;
@property (nonatomic, readonly) ObjectType right;

@end

/**
 * Instantiates an unordered pair with two elements. This is a C function and not
 * an initializer purely because initializers are more verbose.
 */
FUIUnorderedPair *FUIUnorderedPairMake(id left, id right);


@interface FUILCS<__covariant ObjectType> : NSObject

/**
 * Returns the longest common subsequence of two arrays. This method is not useful in itself,
 * but it's exposed here for testability. O(m * n) complexity, where m and n are the sizes of
 * the input arrays.
 */
+ (NSArray *)lcsWithInitialArray:(NSArray<ObjectType> *)initial
                     resultArray:(NSArray<ObjectType> *)result;

@end


@class FIRDocumentChange, FIRDocumentSnapshot;

/**
 * Constructs a diff from two arrays. Initialization is O(m * n), where m and n are the lengths
 * of the input arrays. Construction is expensive, and diffs are not cached.
 */
@interface FUISnapshotArrayDiff<__covariant ObjectType> : NSObject

/** The initial array. */
@property (nonatomic, readonly) NSArray<ObjectType> *initial;

/** The resulting array. */
@property (nonatomic, readonly) NSArray<ObjectType> *result;

/** An array of indexes of deleted items relative to the initial array. */
@property (nonatomic, readonly) NSArray<NSNumber *> *deletedIndexes;

/** An array of objects deleted from the initial array. */
@property (nonatomic, readonly) NSArray<ObjectType> *deletedObjects;

/** An array of the initial indexes of moved items. */
@property (nonatomic, readonly) NSArray<NSNumber *> *movedInitialIndexes;

/** An array of the final indexes of moved items. */
@property (nonatomic, readonly) NSArray<NSNumber *> *movedResultIndexes;

/** An array of objects that were moved. */
@property (nonatomic, readonly) NSArray<ObjectType> *movedObjects;

/** An array of indexes of objects that were changed. */
@property (nonatomic, readonly) NSArray<NSNumber *> *changedIndexes;

/** An array of the resulting objects that were changed. */
@property (nonatomic, readonly) NSArray<ObjectType> *changedObjects;

/** An array of indexes of objects that were inserted, relative to the final array. */
@property (nonatomic, readonly) NSArray<NSNumber *> *insertedIndexes;

/** An array of inserted objects. */
@property (nonatomic, readonly) NSArray<ObjectType> *insertedObjects;

/**
 * Creates a diff between two arrays. This operation is relatively expensive;
 * O(n x m) for arrays of length n and m.
 */
- (instancetype)initWithInitialArray:(NSArray<ObjectType> *)initialArray
                         resultArray:(NSArray<ObjectType> *)resultArray;

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
