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
 * The query backing the array.
 */
@property (nonatomic, readonly, nonnull) FIRDatabaseQuery *query;

/**
 * A closure used to sort the downloaded contents from the Firebase query.
 */
@property (nonatomic, copy, nonnull) NSComparisonResult (^sortDescriptor)(FIRDataSnapshot *, FIRDataSnapshot *);

/**
 * The backing array containing the contents of the collection. This array must
 * always be sorted.
 */
@property (nonatomic, strong) NSMutableArray<FIRDataSnapshot *> *contents;

/**
 * A set containing the query observer handles that should be released when
 * this array is freed.
 */
@property(strong, nonatomic) NSMutableSet<NSNumber *> *handles;

@end

@implementation FUISortedArray

- (instancetype)initWithQuery:(FIRDatabaseQuery *)query
                     delegate:(id<FUICollectionDelegate>)delegate
               sortDescriptor:(NSComparisonResult (^)(FIRDataSnapshot *,
                                                      FIRDataSnapshot *))sortDescriptor {
  self = [super init];
  if (self != nil) {
    _delegate = delegate;
    _query = query;
    _sortDescriptor = sortDescriptor;
    _handles = [NSMutableSet setWithCapacity:4];
  }
  return self;
}

- (void)dealloc {
  [self invalidate];
}

- (void)observeQuery {
  FIRDatabaseHandle handle;
  handle = [self.query observeEventType:FIRDataEventTypeChildAdded
         andPreviousSiblingKeyWithBlock:^(FIRDataSnapshot *snapshot, NSString *previousChildKey) {
    [self insertSnapshot:snapshot];
  }];
  [_handles addObject:@(handle)];

  handle = [self.query observeEventType:FIRDataEventTypeChildChanged
         andPreviousSiblingKeyWithBlock:^(FIRDataSnapshot *snapshot, NSString *previousChildKey) {
    // Remove and re-insert to maintain sortedness. There are faster ways
    // to do this but idgaf
    NSInteger index = [self indexOfSnapshot:snapshot];
    if (index == NSNotFound) { /* error */ return; }

    // Since changes can change ordering, model changes as a deletion and an insertion.
    [self.contents removeObjectAtIndex:index];
    if ([self.delegate respondsToSelector:@selector(array:didRemoveObject:atIndex:)]) {
      [self.delegate array:self didRemoveObject:snapshot atIndex:index];
    }
    
    NSInteger newIndex = [self insertSnapshot:snapshot];
    if ([self.delegate respondsToSelector:@selector(array:didAddObject:atIndex:)]) {
      [self.delegate array:self didAddObject:snapshot atIndex:newIndex];
    }
  }];
  [_handles addObject:@(handle)];

  handle = [self.query observeEventType:FIRDataEventTypeChildRemoved
         andPreviousSiblingKeyWithBlock:^(FIRDataSnapshot *snapshot, NSString *previousSiblingKey) {
    NSInteger index = [self indexOfSnapshot:snapshot];
    if (index == NSNotFound) { /* error */ return; }

    [self.contents removeObjectAtIndex:index];
    if ([self.delegate respondsToSelector:@selector(array:didRemoveObject:atIndex:)]) {
      [self.delegate array:self didRemoveObject:snapshot atIndex:index];
    }
  } withCancelBlock:^(NSError *error) {
    if ([self.delegate respondsToSelector:@selector(array:queryCancelledWithError:)]) {
      [self.delegate array:self queryCancelledWithError:error];
    }
  }];
  [_handles addObject:@(handle)];

  handle = [self.query observeEventType:FIRDataEventTypeChildMoved
         andPreviousSiblingKeyWithBlock:^(FIRDataSnapshot *snapshot, NSString *previousChildKey) {
    // Ignore this event, since we do our own ordering.
  } withCancelBlock:^(NSError *error) {
    if ([self.delegate respondsToSelector:@selector(array:queryCancelledWithError:)]) {
      [self.delegate array:self queryCancelledWithError:error];
    }
  }];
  [_handles addObject:@(handle)];
}

- (NSInteger)indexOfSnapshot:(FIRDataSnapshot *)snapshot {
  NSParameterAssert(snapshot != nil);
  // Don't binary search here because we use snapshot keys
  // for equality; sort descriptor block provides the entire
  // snapshot so binary search isn't reliable. i.e. if the
  // whole array is NSOrderedSame binary search won't work
  for (NSInteger index = 0; index < self.contents.count; index++) {
    if ([self.contents[index].key isEqualToString:snapshot.key]) {
      return index;
    }
  }
  return NSNotFound;
}

- (FIRDataSnapshot *)snapshotAtIndex:(NSInteger)index {
  return self.contents[index];
}

- (NSArray *)items {
  return [self.contents copy];
}

- (NSUInteger)count {
  return self.items.count;
}

- (void)invalidate {
  for (NSNumber *handle in _handles) {
    [_query removeObserverWithHandle:handle.unsignedIntegerValue];
  }
}

- (NSInteger)insertSnapshot:(FIRDataSnapshot *)snapshot {
  if (self.contents.count == 0) {
    [self.contents addObject:snapshot];
    return 0;
  }
  if (self.contents.count == 1) {
    NSComparisonResult result = self.sortDescriptor(snapshot, self.contents[0]);
    switch (result) {
      case NSOrderedDescending:
        [self.contents addObject:snapshot];
        return 1;
      default:
        [self.contents insertObject:snapshot atIndex:0];
        return 0;
    }
  }

  NSInteger index = self.contents.count / 2;
  while (index >= 0 && index <= self.contents.count) {
    if (index == 0) {
      [self.contents insertObject:snapshot atIndex:index];
      return 0;
    }
    if (index == self.contents.count) {
      [self.contents addObject:snapshot];
      return index;
    }

    // Comparison results are as if the item were to be inserted between the two
    // compared objects.
    NSComparisonResult left = self.sortDescriptor(self.contents[index - 1], snapshot);
    NSComparisonResult right = self.sortDescriptor(snapshot, self.contents[index]);

    if (left == NSOrderedDescending && right == NSOrderedAscending) {
      // look left
      index /= 2;
      continue;
    } else if (left == NSOrderedAscending && right == NSOrderedDescending) {
      // look right
      index = ((self.contents.count - index) / 2) + index;
    } else if (left == NSOrderedDescending && right == NSOrderedDescending) {
      // bad state (array is not sorted to begin with)
      NSAssert(NO, @"FUISortedArray %@'s sort descriptor returned inconsistent results!", self);
    } else {
      // good
      [self.contents insertObject:snapshot atIndex:index];
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
