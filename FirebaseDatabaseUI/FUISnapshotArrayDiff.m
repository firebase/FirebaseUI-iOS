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

@end

@implementation FUIUnorderedPair

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
  FUIUnorderedPair *pair = [[FUIUnorderedPair alloc] init];
  pair.left = left;
  pair.right = right;
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
  if (_memo[args] != nil) {
    return _memo[args];
  }

  FUIArraySlice *shorter;
  FUIArraySlice *longer;
  if (lhs.count <= rhs.count) {
    shorter = lhs; longer = rhs;
  } else {
    shorter = rhs; longer = lhs;
  }

  NSMutableArray *aggregate = [NSMutableArray arrayWithCapacity:longer.count];

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
  NSMutableArray *left =
  [self lcsWithInitial:[shorter suffixFromIndex:shortOffset + aggregate.count + 1]
                result:[longer suffixFromIndex:longOffset + aggregate.count]];
  NSMutableArray *right =
  [self lcsWithInitial:[shorter suffixFromIndex:shortOffset + aggregate.count]
                result:[longer suffixFromIndex:longOffset + aggregate.count + 1]];

  // Return the aggregate plus the greater of the two subsequences.
  if (left.count > right.count) {
    [aggregate addObjectsFromArray:left];
  } else {
    [aggregate addObjectsFromArray:right];
  }

  _memo[args] = aggregate;
  return aggregate;
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

  // A set of indexes of deleted elements, used later to decide if insertions should be
  // counted as changes.
  NSMutableSet<NSNumber *> *removedIndexes = [NSMutableSet set];

  NSMutableArray<NSNumber *> *deletedIndexes = [NSMutableArray arrayWithCapacity:_initial.count];
  NSMutableArray *deletedObjects = [NSMutableArray arrayWithCapacity:_initial.count];

  NSMutableArray<NSNumber *> *insertedIndexes = [NSMutableArray arrayWithCapacity:_result.count];
  NSMutableArray *insertedObjects = [NSMutableArray arrayWithCapacity:_result.count];

  NSMutableArray<NSNumber *> *changedIndexes = [NSMutableArray arrayWithCapacity:_initial.count];
  NSMutableArray *changedObjects = [NSMutableArray arrayWithCapacity:_initial.count];

  NSMutableArray<NSNumber *> *movedInitialIndexes = [NSMutableArray arrayWithCapacity:16];
  NSMutableArray<NSNumber *> *movedResultIndexes = [NSMutableArray arrayWithCapacity:16];
  NSMutableArray *movedObjects = [NSMutableArray arrayWithCapacity:16];

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
      [removedIndexes addObject:@(i)];
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
      // If we're inserting at the same index that a deletion previously took place,
      // count it as an in-place change instead.
      if ([removedIndexes containsObject:@(i)]) {
        [removedIndexes removeObject:@(i)];
        [changedObjects addObject:object];
        [changedIndexes addObject:@(i)];

        // Changes can no longer be considered moves, so remove them from the moves dict.
        [deleted[object] removeObject:@(i)];
        continue;
      }

      // Insertion of a previously deleted element should be counted as a move.
      if (deleted[object].count > 0) {
        NSNumber *initialIndex = deleted[object].anyObject;
        [deleted[object] removeObject:initialIndex];
        [movedObjects addObject:object];
        [movedInitialIndexes addObject:initialIndex];
        [movedResultIndexes addObject:@(i)];
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

- (NSString *)description {
  return [NSString stringWithFormat:@"%@\n Deleted: %@\n Moved: %@\n Changed: %@\n Inserted: %@\n",
          [super description], _deletedObjects, _movedObjects, _changedObjects, _insertedObjects];
}

@end
