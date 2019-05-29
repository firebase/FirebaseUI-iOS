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

#import "FUISortedArray.h"

@interface FUISortedArray ()

/**
 * A closure used to sort the downloaded contents from the Firebase query.
 */
@property (nonatomic, copy, nonnull) NSComparisonResult (^sortDescriptor)(FIRDataSnapshot *, FIRDataSnapshot *);

/**
 * The backing collection that holds all of the array's data.
 */
@property (strong, nonatomic) NSMutableArray<FIRDataSnapshot *> *snapshots;

/**
 * The backing collection that holds all of the array's keys.
 */
@property (strong, nonatomic) NSMutableArray<NSString *> *keys;

/**
 * A set containing the query observer handles that should be released when
 * this array is freed.
 */
@property(strong, nonatomic) NSMutableSet<NSNumber *> *handles;

@end

@implementation FUISortedArray
// Cheating at subclassing, but this @dynamic avoids
// duplicating storage without exposing mutability publicly
@dynamic snapshots, handles;

- (instancetype)initWithQuery:(FIRDatabaseQuery *)query
                     delegate:(id<FUICollectionDelegate>)delegate
               sortDescriptor:(NSComparisonResult (^)(FIRDataSnapshot *,
                                                      FIRDataSnapshot *))sortDescriptor {
  self = [super initWithQuery:query delegate:delegate];
  if (self != nil) {
    _sortDescriptor = sortDescriptor;
  }
  return self;
}

- (void)insertSnapshot:(FIRDataSnapshot *)snap withPreviousChildKey:(NSString *)previous {
  NSInteger index = [self insertSnapshot:snap];
  if ([self.delegate respondsToSelector:@selector(array:didAddObject:atIndex:)]) {
    [self.delegate array:self didAddObject:snap atIndex:index];
  }
}

- (void)removeSnapshot:(FIRDataSnapshot *)snap withPreviousChildKey:(NSString *)previous {
  NSInteger index = [self indexForKey:snap.key];
  if (index == NSNotFound) { /* error */ return; }

  [self.snapshots removeObjectAtIndex:index];
  [self.keys removeObjectAtIndex:index];
  if ([self.delegate respondsToSelector:@selector(array:didRemoveObject:atIndex:)]) {
    [self.delegate array:self didRemoveObject:snap atIndex:index];
  }
}

- (void)changeSnapshot:(FIRDataSnapshot *)snap withPreviousChildKey:(NSString *)previous {
  // Remove and re-insert to maintain sortedness. There are faster ways
  // to do this but idgaf
  NSInteger index = [self indexForKey:snap.key];
  if (index == NSNotFound) { /* error */ return; }

  // Since changes can change ordering, model changes as a deletion and an insertion.
  FIRDataSnapshot *removed = [self snapshotAtIndex:index];
  [self.snapshots removeObjectAtIndex:index];
  [self.keys removeObjectAtIndex:index];
  if ([self.delegate respondsToSelector:@selector(array:didRemoveObject:atIndex:)]) {
    [self.delegate array:self didRemoveObject:removed atIndex:index];
  }

  NSInteger newIndex = [self insertSnapshot:snap];
  if ([self.delegate respondsToSelector:@selector(array:didAddObject:atIndex:)]) {
    [self.delegate array:self didAddObject:snap atIndex:newIndex];
  }
}

- (void)moveSnapshot:(FIRDataSnapshot *)snap withPreviousChildKey:(NSString *)previous {
  // Ignore this event, since we do our own ordering.
}

- (NSArray *)items {
  return super.items;
}

- (NSInteger)insertSnapshot:(FIRDataSnapshot *)snapshot {
  if (self.count == 0) {
    [self.snapshots addObject:snapshot];
    [self.keys addObject:snapshot.key];
    return 0;
  }
  if (self.count == 1) {
    NSComparisonResult result = self.sortDescriptor(snapshot, [self snapshotAtIndex:0]);
    switch (result) {
      case NSOrderedDescending:
        [self.snapshots addObject:snapshot];
        [self.keys addObject:snapshot.key];
        return 1;
      default:
        [self.snapshots insertObject:snapshot atIndex:0];
        [self.keys insertObject:snapshot.key atIndex:0];
        return 0;
    }
  }

  NSInteger lowerBound = 0;
  NSInteger upperBound = self.snapshots.count;
  NSInteger index = self.count / 2;
  while (index >= 0 && index <= upperBound) {

    if (index == 0) {
      [self.snapshots insertObject:snapshot atIndex:0];
      [self.keys insertObject:snapshot.key atIndex:0];
      return 0;
    }
    if (index == self.snapshots.count) {
      [self.snapshots addObject:snapshot];
      [self.keys addObject:snapshot.key];
      return index;
    }

    // Comparison results are as if the item were to be inserted between the two
    // compared objects.
    NSComparisonResult left = self.sortDescriptor([self snapshotAtIndex:index - 1], snapshot);
    NSComparisonResult right = self.sortDescriptor(snapshot, [self snapshotAtIndex:index]);

    if (left == NSOrderedDescending && right == NSOrderedAscending) {
      // look left
      upperBound = index;
      index = (lowerBound + upperBound) / 2;
      continue;
    } else if (left == NSOrderedAscending && right == NSOrderedDescending) {
      // look right
      lowerBound = index + 1;
      index = (lowerBound + upperBound) / 2;
      continue;
    } else if (left == NSOrderedDescending && right == NSOrderedDescending) {
      // bad state (array is not sorted to begin with)
      NSAssert(NO, @"FUISortedArray %@'s sort descriptor returned inconsistent results!", self);
    } else {
      // good
      [self.snapshots insertObject:snapshot atIndex:index];
      [self.keys insertObject:snapshot.key atIndex:index];
      return index;
    }
  }
  // should be unreachable, but compiler has no way of knowing array is
  // always supposed to be sorted.
  NSAssert(NO, @"Failed to insert new snapshot: Either sortDescriptor returned inconsistent "
           @"results or this is a bug in FirebaseUI");
  abort();
}

@end
