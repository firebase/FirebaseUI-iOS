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

#import "FUIArray.h"

@interface FUIArray ()

/**
 * The backing collection that holds all of the array's data.
 */
@property (strong, nonatomic) NSMutableArray<FIRDataSnapshot *> *snapshots;

/**
 * A set containing the query observer handles that should be released when
 * this array is freed.
 */
@property (strong, nonatomic) NSMutableSet<NSNumber *> *handles;

@end

@implementation FUIArray

#pragma mark - Initializer methods

- (instancetype)initWithQuery:(FIRDatabaseQuery *)query delegate:(id<FUICollectionDelegate>)delegate {
  NSParameterAssert(query != nil);
  self = [super init];
  if (self) {
    self.snapshots = [NSMutableArray array];
    self.query = query;
    self.handles = [NSMutableSet setWithCapacity:4];
    self.delegate = delegate;
  }
  return self;
}

- (instancetype)initWithQuery:(id<FUIDataObservable>)query {
  return [self initWithQuery:query delegate:nil];
}

+ (instancetype)arrayWithQuery:(id<FUIDataObservable>)query {
  return [[self alloc] initWithQuery:query];
}

#pragma mark - Memory management methods

- (void)dealloc {
  [self invalidate];
}

#pragma mark - Private API methods

- (void)observeQuery {
  if (self.handles.count == 4) { /* don't duplicate observers */ return; }
  FIRDatabaseHandle handle;
  handle = [self.query observeEventType:FIRDataEventTypeChildAdded
      andPreviousSiblingKeyWithBlock:^(FIRDataSnapshot *snapshot, NSString *previousChildKey) {
        [self insertSnapshot:snapshot withPreviousChildKey:previousChildKey];
      }
      withCancelBlock:^(NSError *error) {
        if ([self.delegate respondsToSelector:@selector(array:queryCancelledWithError:)]) {
          [self.delegate array:self queryCancelledWithError:error];
        }
      }];
  [_handles addObject:@(handle)];

  handle = [self.query observeEventType:FIRDataEventTypeChildChanged
      andPreviousSiblingKeyWithBlock:^(FIRDataSnapshot *snapshot, NSString *previousChildKey) {
        [self changeSnapshot:snapshot withPreviousChildKey:previousChildKey];
      }
      withCancelBlock:^(NSError *error) {
        if ([self.delegate respondsToSelector:@selector(array:queryCancelledWithError:)]) {
          [self.delegate array:self queryCancelledWithError:error];
        }
      }];
  [_handles addObject:@(handle)];

  handle = [self.query observeEventType:FIRDataEventTypeChildRemoved
      andPreviousSiblingKeyWithBlock:^(FIRDataSnapshot *snapshot, NSString *previousSiblingKey) {
        [self removeSnapshot:snapshot withPreviousChildKey:previousSiblingKey];
      }
      withCancelBlock:^(NSError *error) {
        if ([self.delegate respondsToSelector:@selector(array:queryCancelledWithError:)]) {
          [self.delegate array:self queryCancelledWithError:error];
        }
      }];
  [_handles addObject:@(handle)];

  handle = [self.query observeEventType:FIRDataEventTypeChildMoved
      andPreviousSiblingKeyWithBlock:^(FIRDataSnapshot *snapshot, NSString *previousChildKey) {
        [self moveSnapshot:snapshot withPreviousChildKey:previousChildKey];
      }
      withCancelBlock:^(NSError *error) {
        if ([self.delegate respondsToSelector:@selector(array:queryCancelledWithError:)]) {
          [self.delegate array:self queryCancelledWithError:error];
        }
      }];
  [_handles addObject:@(handle)];
}

- (void)invalidate {
  for (NSNumber *handle in _handles) {
    [_query removeObserverWithHandle:handle.unsignedIntegerValue];
  }
}

- (NSUInteger)indexForKey:(NSString *)key {
  NSParameterAssert(key != nil);

  for (NSUInteger index = 0; index < [self.snapshots count]; index++) {
    if ([key isEqualToString:[(FIRDataSnapshot *)[self.snapshots objectAtIndex:index] key]]) {
      return index;
    }
  }
  return NSNotFound;
}

- (void)insertSnapshot:(FIRDataSnapshot *)snap withPreviousChildKey:(NSString *)previous {
  NSUInteger index = 0;
  if (previous != nil) {
    index = [self indexForKey:previous] + 1;
  }

  [self.snapshots insertObject:snap atIndex:index];

  if ([self.delegate respondsToSelector:@selector(array:didAddObject:atIndex:)]) {
    [self.delegate array:self didAddObject:snap atIndex:index];
  }
}

- (void)removeSnapshot:(FIRDataSnapshot *)snap withPreviousChildKey:(NSString *)previous {
  NSUInteger index = [self indexForKey:snap.key];

  [self.snapshots removeObjectAtIndex:index];

  if ([self.delegate respondsToSelector:@selector(array:didRemoveObject:atIndex:)]) {
    [self.delegate array:self didRemoveObject:snap atIndex:index];
  }
}

- (void)changeSnapshot:(FIRDataSnapshot *)snap withPreviousChildKey:(NSString *)previous {
  NSUInteger index = [self indexForKey:snap.key];

  [self.snapshots replaceObjectAtIndex:index withObject:snap];

  if ([self.delegate respondsToSelector:@selector(array:didChangeObject:atIndex:)]) {
    [self.delegate array:self didChangeObject:snap atIndex:index];
  }
}

- (void)moveSnapshot:(FIRDataSnapshot *)snap withPreviousChildKey:(NSString *)previous {
  NSUInteger fromIndex = [self indexForKey:snap.key];
  [self.snapshots removeObjectAtIndex:fromIndex];

  NSUInteger toIndex = 0;
  if (previous != nil) {
    NSUInteger prevIndex = [self indexForKey:previous];
    if (prevIndex != NSNotFound) {
      toIndex = prevIndex + 1;
    }
  }
  [self.snapshots insertObject:snap atIndex:toIndex];

  if ([self.delegate respondsToSelector:@selector(array:didMoveObject:fromIndex:toIndex:)]) {
    [self.delegate array:self didMoveObject:snap fromIndex:fromIndex toIndex:toIndex];
  }
}

- (void)removeSnapshotAtIndex:(NSUInteger)index {
  [self.snapshots removeObjectAtIndex:index];
}

- (void)insertSnapshot:(FIRDataSnapshot *)snap atIndex:(NSUInteger)index {
  [self.snapshots insertObject:snap atIndex:index];
}

- (void)addSnapshot:(FIRDataSnapshot *)snap {
  [self.snapshots addObject:snap];
}

#pragma mark - Public API methods

- (NSArray *)items {
  return [self.snapshots copy];
}

- (NSUInteger)count {
  return [self.snapshots count];
}

- (FIRDataSnapshot *)snapshotAtIndex:(NSInteger)index {
  return (FIRDataSnapshot *)[self.snapshots objectAtIndex:index];
}

- (FIRDatabaseReference *)refForIndex:(NSUInteger)index {
  return [(FIRDataSnapshot *)[self.snapshots objectAtIndex:index] ref];
}

- (id)objectAtIndexedSubscript:(NSUInteger)index {
  return [self snapshotAtIndex:index];
}

- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)index{
  @throw [NSException exceptionWithName:@"FUIArraySetIndexWithSubscript"
                                 reason:@"Setting an object as FUIArray[i] is not supported."
                               userInfo:nil];
}

@end
