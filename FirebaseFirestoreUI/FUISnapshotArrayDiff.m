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

@interface FUIArraySlice ()

@end

@implementation FUIArraySlice

- (instancetype)init {
  return [self initWithArray:@[] startIndex:0 length:0];
}

- (instancetype)initWithArray:(NSArray *)array startIndex:(NSInteger)start length:(NSInteger)length {
  NSParameterAssert(start >= 0);
  NSParameterAssert(length >= 0);
  NSParameterAssert(start + length <= array.count);
  self = [super init];
  if (self != nil) {
    _startIndex = start;
    _count = length;
    _backingArray = [array copy];
  }
  return self;
}

- (instancetype)initWithArray:(NSArray *)array startIndex:(NSInteger)start endIndex:(NSInteger)end {
  NSInteger length = end - start;
  NSAssert(length >= 0, @"Cannot create array slice with length less than zero");
  return [self initWithArray:array startIndex:start length:length];
}

- (instancetype)initWithArray:(NSArray *)array {
  return [self initWithArray:array startIndex:0 length:array.count];
}

- (id)objectAtIndex:(NSInteger)index {
  NSAssert(index >= self.startIndex && index < self.endIndex, @"Index out of bounds");
  return self.backingArray[index];
}

- (id)objectAtIndexedSubscript:(NSInteger)index {
  return [self objectAtIndex:index];
}

- (FUIArraySlice *)suffixFromIndex:(NSInteger)index {
  return [[FUIArraySlice alloc] initWithArray:self.backingArray
                                   startIndex:index
                                     endIndex:self.endIndex];
}

- (NSInteger)endIndex {
  return self.startIndex + self.count;
}

- (NSUInteger)hash {
  NSUInteger hash = 5381;
  for (NSInteger i = self.startIndex; i < self.endIndex; i++) {
    NSUInteger intermediate = [self.backingArray[i] hash];
    hash = (hash << 5) + hash + intermediate;
  }
  return hash;
}

- (BOOL)isEqual:(FUIArraySlice *)object {
  if (![object isKindOfClass:[self class]]) { return NO; }
  if (object.count != self.count) { return NO; }
  if (object.startIndex != self.startIndex) { return NO; }

  for (NSInteger i = self.startIndex; i < self.endIndex; i++) {
    if (![[object objectAtIndex:i] isEqual:[self objectAtIndex:i]]) {
      return NO;
    }
  }

  return YES;
}

@end


@interface FUIUnorderedPair ()

@property (nonatomic, readwrite) id left;
@property (nonatomic, readwrite) id right;

- (instancetype)initWithLeft:(id)left right:(id)right NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end

@implementation FUIUnorderedPair

- (instancetype)init {
  abort();
}

- (instancetype)initWithLeft:(id)left right:(id)right {
  self = [super init];
  if (self != nil) {
    _left = left;
    _right = right;
  }
  return self;
}

- (NSUInteger)hash {
  return [self.left hash] ^ [self.right hash];
}

- (BOOL)isEqual:(FUIUnorderedPair *)object {
  if (![object isKindOfClass:[self class]]) { return NO; }
  return ([self.left isEqual:object.left] && [self.right isEqual:object.right]) ||
      ([self.right isEqual:object.left] && [self.left isEqual:object.right]);
}

// This class is immutable, so copies just return self.
- (id)copyWithZone:(NSZone *)zone {
  return self;
}

- (id)copy {
  return self;
}

@end

FUIUnorderedPair *FUIUnorderedPairMake(id left, id right) {
  FUIUnorderedPair *pair = [[FUIUnorderedPair alloc] initWithLeft:left right:right];
  return pair;
}

@interface FUILCS ()
@property (nonatomic, readonly) NSMutableDictionary<FUIUnorderedPair<FUIArraySlice<id> *> *, NSMutableArray<id> *> *memo;
@end

@implementation FUILCS

- (instancetype)init {
  self = [super init];
  if (self != nil) {
    _memo = [NSMutableDictionary dictionary];
  }
  return self;
}

- (NSMutableArray *)lcsWithInitial:(FUIArraySlice *)lhs result:(FUIArraySlice *)rhs {
  if (lhs.count == 0 && rhs.count == 0) {
    return [NSMutableArray array];
  }

  FUIUnorderedPair *args = FUIUnorderedPairMake(lhs, rhs);
  NSMutableArray *memoized = _memo[args];
  if (memoized != nil) {
    return memoized;
  }

  @autoreleasepool {
    FUIArraySlice *shorter;
    FUIArraySlice *longer;
    if (lhs.count <= rhs.count) {
      shorter = lhs; longer = rhs;
    } else {
      shorter = rhs; longer = lhs;
    }

    NSMutableArray *aggregate = [NSMutableArray arrayWithCapacity:shorter.count];

    // Aggregate common elements.
    NSInteger shortOffset = shorter.startIndex;
    NSInteger longOffset  = longer.startIndex;
    for (NSInteger i = 0; i < shorter.count; i++) {
      if ([shorter[i + shortOffset] isEqual:longer[i + longOffset]]) {
        [aggregate addObject:shorter[i + shortOffset]];
      } else {
        break;
      }
    }

    // LCS is the entire shorter collection.
    if (aggregate.count == shorter.count) {
      _memo[args] = aggregate;
      return aggregate;
    }

    // Reached uncommon element, so try LCS of both sides minus the uncommon element or any
    // previously aggregated common elements.
    NSMutableArray *right =
        [self lcsWithInitial:[shorter suffixFromIndex:shortOffset + aggregate.count]
                      result:[longer suffixFromIndex:longOffset + aggregate.count + 1]];

    // Exit early, avoiding one recurse
    if (right.count == shorter.count) {
      [aggregate addObjectsFromArray:right];
      _memo[args] = aggregate;
      return aggregate;
    }

    NSMutableArray *left =
        [self lcsWithInitial:[shorter suffixFromIndex:shortOffset + aggregate.count + 1]
                      result:[longer suffixFromIndex:longOffset + aggregate.count]];

    // Return the aggregate plus the greater of the two subsequences.
    if (left.count > right.count) {
      [aggregate addObjectsFromArray:left];
    } else {
      [aggregate addObjectsFromArray:right];
    }

    _memo[args] = aggregate;
    return aggregate;
  }
}

+ (NSArray *)lcsWithInitialArray:(NSArray *)initial resultArray:(NSArray *)result {
  FUILCS *lcs = [[FUILCS alloc] init];
  FUIArraySlice *left = [[FUIArraySlice alloc] initWithArray:initial];
  FUIArraySlice *right = [[FUIArraySlice alloc] initWithArray:result];
  return [[lcs lcsWithInitial:left result:right] copy];
}

@end


@implementation FUISnapshotArrayDiff

- (instancetype)initWithInitialArray:(NSArray *)initialArray resultArray:(NSArray *)resultArray {
  self = [super init];
  if (self != nil) {
    _initial = [initialArray copy];
    _result = [resultArray copy];
    [self buildDiffs];
  }
  return self;
}

- (void)buildDiffs {
  NSArray *lcs = [FUILCS lcsWithInitialArray:_initial resultArray:_result];

  // A map of deleted elements and their indexes, which will be used later to convert
  // deletes into moves. These must be arrays since objects may not be unique.
  NSMutableDictionary<id, NSMutableSet<NSNumber *> *> *deleted =
      [NSMutableDictionary dictionaryWithCapacity:_initial.count];

  NSMutableArray<NSNumber *> *deletedIndexes = [NSMutableArray arrayWithCapacity:_initial.count];
  NSMutableArray *deletedObjects = [NSMutableArray arrayWithCapacity:_initial.count];

  NSMutableArray<NSNumber *> *insertedIndexes = [NSMutableArray arrayWithCapacity:_result.count];
  NSMutableArray *insertedObjects = [NSMutableArray arrayWithCapacity:_result.count];

  NSMutableArray<NSNumber *> *changedIndexes = [NSMutableArray arrayWithCapacity:_initial.count];
  NSMutableArray *changedObjects = [NSMutableArray arrayWithCapacity:_initial.count];

  NSMutableArray<NSNumber *> *movedInitialIndexes = [NSMutableArray array];
  NSMutableArray<NSNumber *> *movedResultIndexes = [NSMutableArray array];
  NSMutableArray *movedObjects = [NSMutableArray array];

  // Build the array of deleted items by examining the initial array and LCS.
  // All deleted items and their indexes go into the dictionary of deleted stuff,
  // so we can tell later on which ones should be moves and which ones should be deletes.
  NSInteger lcsIndex = 0;
  for (NSInteger i = 0; i < _initial.count; i++) {
    id object = _initial[i];
    id lcsObject;
    if (lcsIndex < lcs.count) { lcsObject = lcs[lcsIndex]; }
    id resultObject;
    if (i < _result.count) { resultObject = _result[i]; }
    if ([lcsObject isEqual:object]) {
      lcsIndex++;
    } else {
      // All missing elements are treated as deletions for now and then revised later.
      [deletedIndexes addObject:@(i)];
      [deletedObjects addObject:object];

      if (deleted[object] == nil) {
        deleted[object] = [NSMutableSet setWithObject:@(i)];
      } else {
        [deleted[object] addObject:@(i)];
      }
    }
  }

  // Build everything that's not a delete. Changes come first, then moves, then insertions.
  // Moves are considered insertions of a previously deleted element, unless
  // that element was a part of a change.
  lcsIndex = 0;
  for (NSInteger i = 0; i < _result.count; i++) {
    id initialObject;
    if (i < _initial.count) { initialObject = _initial[i]; }
    id lcsObject;
    if (lcsIndex < lcs.count) { lcsObject = lcs[lcsIndex]; }
    id object = _result[i];
    if ([lcsObject isEqual:object]) {
      lcsIndex++;
    } else {
      // Insertion of a previously deleted element should be counted as a move.
      if (deleted[object].count > 0) {
        NSNumber *initialIndex = deleted[object].anyObject;
        [deleted[object] removeObject:initialIndex];
        [movedObjects addObject:object];
        [movedInitialIndexes addObject:initialIndex];
        [movedResultIndexes addObject:@(i)];
        continue;
      }

      // If we're inserting at the same index that a deletion previously took place,
      // count it as an in-place change instead.
      if ([deleted[object] containsObject:@(i)]) {
        [changedObjects addObject:object];
        [changedIndexes addObject:@(i)];

        // Changes can no longer be considered moves, so remove them from the moves dict.
        [deleted[object] removeObject:@(i)];
        continue;
      }

      // Otherwise, this is just an insertion.
      [insertedIndexes addObject:@(i)];
      [insertedObjects addObject:object];
    }
  }

  // Finally, remove deletions that were later counted as moves/changes.
  NSMutableArray *oldDeletions = deletedObjects;
  NSMutableArray *oldIndexes = deletedIndexes;
  NSSet<NSNumber *> *changes = [NSSet setWithArray:movedInitialIndexes];
  changes = [changes setByAddingObjectsFromArray:changedIndexes];
  deletedObjects = [NSMutableArray arrayWithCapacity:oldDeletions.count];
  deletedIndexes = [NSMutableArray arrayWithCapacity:oldIndexes.count];
  for (NSInteger i = 0; i < oldDeletions.count; i++) {
    if ([changes containsObject:oldIndexes[i]]) { continue; }
    [deletedObjects addObject:oldDeletions[i]];
    [deletedIndexes addObject:oldIndexes[i]];
  }

  _deletedIndexes = [deletedIndexes copy];
  _deletedObjects = [deletedObjects copy];

  _insertedIndexes = [insertedIndexes copy];
  _insertedObjects = [insertedObjects copy];

  _changedIndexes = [changedIndexes copy];
  _changedObjects = [changedObjects copy];

  _movedInitialIndexes = [movedInitialIndexes copy];
  _movedResultIndexes = [movedResultIndexes copy];
  _movedObjects = [movedObjects copy];
}

- (instancetype)initWithInitialArray:(NSArray<FIRDocumentSnapshot *> *)initial
                         resultArray:(NSArray<FIRDocumentSnapshot *> *)result
                     documentChanges:(NSArray<FIRDocumentChange *> *)documentChanges {
  // TODO(morganchen): this needs to be tested with valid documentChange arrays from Firestore.
  self = [super init];
  if (self != nil) {
    _initial = [initial copy];
    _result = [result copy];
    [self buildDiffsFromDocumentChanges:documentChanges];
  }
  return self;
}

- (void)buildDiffsFromDocumentChanges:(NSArray<FIRDocumentChange *> *)documentChanges {
  NSMutableDictionary<NSString *, NSNumber *> *oldIndexes =
      [NSMutableDictionary dictionaryWithCapacity:_initial.count];
  NSMutableDictionary<NSString *, NSNumber *> *newIndexes =
      [NSMutableDictionary dictionaryWithCapacity:_result.count];

  NSArray<FIRDocumentSnapshot *> *initial = _initial;
  NSArray<FIRDocumentSnapshot *> *result = _result;

  // Ignore the FIRDocumentChange indexing, since we do our own
  for (NSInteger i = 0; i < _initial.count; i++) {
    oldIndexes[initial[i].documentID] = @(i);
  }
  for (NSInteger i = 0; i < _result.count; i++) {
    newIndexes[result[i].documentID] = @(i);
  }

  NSMutableArray<NSNumber *> *deletedIndexes = [NSMutableArray array];
  NSMutableArray *deletedObjects = [NSMutableArray array];

  NSMutableArray<NSNumber *> *insertedIndexes = [NSMutableArray array];
  NSMutableArray *insertedObjects = [NSMutableArray array];

  NSMutableArray<NSNumber *> *changedIndexes = [NSMutableArray array];
  NSMutableArray *changedObjects = [NSMutableArray array];

  NSMutableArray<NSNumber *> *movedInitialIndexes = [NSMutableArray array];
  NSMutableArray<NSNumber *> *movedResultIndexes = [NSMutableArray array];
  NSMutableArray *movedObjects = [NSMutableArray array];

  NSMutableSet<FIRDocumentSnapshot *> *movedSnapshots = [NSMutableSet set];

  for (FIRDocumentChange *change in documentChanges) {
    FIRDocumentSnapshot *snapshot = change.document;
    NSNumber *oldIndex = oldIndexes[snapshot.documentID];
    NSNumber *newIndex = newIndexes[snapshot.documentID];
    if (oldIndex == nil && newIndex == nil) { continue; }
    switch (change.type) {
      case FIRDocumentChangeTypeRemoved:
        // Ignore deletions that weren't in the original array.
        if (oldIndex == nil) { continue; }
        // Deletions that were then added again should be counted as moves.
        if (newIndex != nil) {
          [movedInitialIndexes addObject:oldIndex];
          [movedResultIndexes addObject:newIndex];
          [movedObjects addObject:snapshot];

          // Keep track of which insertions we should ignore later.
          [movedSnapshots addObject:snapshot];
        } else {
          [deletedIndexes addObject:oldIndex];
          [deletedObjects addObject:snapshot];
        }
        continue;
      case FIRDocumentChangeTypeModified:
        // Don't try to reload changes that weren't in the initial and result arrays.
        if (newIndex == nil || oldIndex == nil) { continue; }
        // This should be counted as a move.
        if (![newIndex isEqualToNumber:oldIndex]) {
          [movedInitialIndexes addObject:oldIndex];
          [movedResultIndexes addObject:newIndex];
          [movedObjects addObject:snapshot];

          // Keep track of which insertions we should ignore later.
          [movedSnapshots addObject:snapshot];
        } else {
          [changedIndexes addObject:oldIndex];
          [changedObjects addObject:snapshot];
        }
        continue;
      case FIRDocumentChangeTypeAdded:
        // Ignore insertions that were later removed.
        if (newIndex == nil) { continue; }
        // Ignore insertions of previously removed items, since those are
        // counted as moves.
        if (oldIndex != nil) { continue; }
        // Ignore insertions that we consider moves.
        if ([movedSnapshots containsObject:snapshot]) { continue; }
        [insertedIndexes addObject:newIndex];
        [insertedObjects addObject:snapshot];
        continue;
    }
  }

  _deletedIndexes = [deletedIndexes copy];
  _deletedObjects = [deletedObjects copy];

  _insertedIndexes = [insertedIndexes copy];
  _insertedObjects = [insertedObjects copy];

  _changedIndexes = [changedIndexes copy];
  _changedObjects = [changedObjects copy];

  _movedInitialIndexes = [movedInitialIndexes copy];
  _movedResultIndexes = [movedResultIndexes copy];
  _movedObjects = [movedObjects copy];
}

- (NSString *)description {
  NSMutableString *result =
      [NSMutableString stringWithFormat:@"<%@: %p ", NSStringFromClass([self class]), self];

  NSMutableString *deleted = [@"Deleted: (\n" mutableCopy];
  for (NSInteger i = 0; i < _deletedIndexes.count; i++) {
    NSNumber *index = _deletedIndexes[i];
    id object = _deletedObjects[i];
    [deleted appendFormat:@"  %li, %@\n", (long)index.integerValue, object];
  }
  [deleted appendString:@")\n"];

  [result appendString:deleted];

  NSMutableString *moved = [@"Moved: (\n" mutableCopy];
  for (NSInteger i = 0; i < _movedInitialIndexes.count; i++) {
    NSNumber *initial = _movedInitialIndexes[i];
    NSNumber *final = _movedResultIndexes[i];
    id object = _movedObjects[i];
    [moved appendFormat:@"  %li -> %li, %@\n",
        (long)initial.integerValue, (long)final.integerValue, object];
  }
  [moved appendString:@")\n"];

  [result appendString:moved];

  NSMutableString *changed = [@"Changed: (\n" mutableCopy];
  for (NSInteger i = 0; i < _changedIndexes.count; i++) {
    NSNumber *index = _changedIndexes[i];
    id object = _changedObjects[i];
    [changed appendFormat:@"  %li, %@\n", (long)index.integerValue, object];
  }
  [changed appendString:@")\n"];

  [result appendString:changed];

  NSMutableString *inserted = [@"Inserted: (\n" mutableCopy];
  for (NSInteger i = 0; i < _insertedIndexes.count; i++) {
    NSNumber *index = _insertedIndexes[i];
    id object = _insertedObjects[i];
    [inserted appendFormat:@"  %li, %@\n", (long)index.integerValue, object];
  }
  [inserted appendString:@")\n"];

  [result appendString:inserted];
  [result appendString:@">"];

  return [result copy];
}

@end
