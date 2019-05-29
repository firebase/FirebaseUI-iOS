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
 * The backing collection that holds all of the array's keys.
 */
@property (strong, nonatomic) NSMutableArray<NSString *> *keys;

/**
 * A set containing the query observer handles that should be released when
 * this array is freed.
 */
@property (strong, nonatomic) NSMutableSet<NSNumber *> *handles;

/**
 * Set to YES when any event that isn't a value event is received; set
 * back to NO when receiving a value event.
 * Used to keep track of whether or not the array is updating so consumers
 * can more easily batch updates.
 */
@property (nonatomic, assign) BOOL isSendingUpdates;

@end

@implementation FUIArray

#pragma mark - Initializer methods

- (instancetype)initWithQuery:(FIRDatabaseQuery *)query delegate:(id<FUICollectionDelegate>)delegate {
  NSParameterAssert(query != nil);
  self = [super init];
  if (self) {
    self.snapshots = [NSMutableArray array];
    self.keys = [NSMutableArray array];
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
  if (self.handles.count == 5) { /* don't duplicate observers */ return; }
  FIRDatabaseHandle handle;
  handle = [self.query observeEventType:FIRDataEventTypeChildAdded
      andPreviousSiblingKeyWithBlock:^(FIRDataSnapshot *snapshot, NSString *previousChildKey) {
        [self didUpdate];
        [self insertSnapshot:snapshot withPreviousChildKey:previousChildKey];
      }
      withCancelBlock:^(NSError *error) {
        [self raiseError:error];
      }];
  [_handles addObject:@(handle)];

  handle = [self.query observeEventType:FIRDataEventTypeChildChanged
      andPreviousSiblingKeyWithBlock:^(FIRDataSnapshot *snapshot, NSString *previousChildKey) {
        [self didUpdate];
        [self changeSnapshot:snapshot withPreviousChildKey:previousChildKey];
      }
      withCancelBlock:^(NSError *error) {
        [self raiseError:error];
      }];
  [_handles addObject:@(handle)];

  handle = [self.query observeEventType:FIRDataEventTypeChildRemoved
      andPreviousSiblingKeyWithBlock:^(FIRDataSnapshot *snapshot, NSString *previousSiblingKey) {
        [self didUpdate];
        [self removeSnapshot:snapshot withPreviousChildKey:previousSiblingKey];
      }
      withCancelBlock:^(NSError *error) {
        [self raiseError:error];
      }];
  [_handles addObject:@(handle)];

  handle = [self.query observeEventType:FIRDataEventTypeChildMoved
      andPreviousSiblingKeyWithBlock:^(FIRDataSnapshot *snapshot, NSString *previousChildKey) {
        [self didUpdate];
        [self moveSnapshot:snapshot withPreviousChildKey:previousChildKey];
      }
      withCancelBlock:^(NSError *error) {
        [self raiseError:error];
      }];
  [_handles addObject:@(handle)];

  handle = [self.query observeEventType:FIRDataEventTypeValue
      andPreviousSiblingKeyWithBlock:^(FIRDataSnapshot *snapshot, NSString *previousChildKey) {
        [self didFinishUpdates];
      }
      withCancelBlock:^(NSError *error) {
        [self raiseError:error];
      }];
  [_handles addObject:@(handle)];
}

// Must be called from every non-value event listener in order to work correctly.
- (void)didUpdate {
  if (self.isSendingUpdates) {
    return;
  }
  self.isSendingUpdates = YES;
  if ([self.delegate respondsToSelector:@selector(arrayDidBeginUpdates:)]) {
    [self.delegate arrayDidBeginUpdates:self];
  }
}

// Must be called from a value event listener.
- (void)didFinishUpdates {
  if (!self.isSendingUpdates) { /* This is probably an error */ return; }
  self.isSendingUpdates = NO;
  if ([self.delegate respondsToSelector:@selector(arrayDidEndUpdates:)]) {
    [self.delegate arrayDidEndUpdates:self];
  }
}

- (void)raiseError:(NSError *)error {
  if ([self.delegate respondsToSelector:@selector(array:queryCancelledWithError:)]) {
    [self.delegate array:self queryCancelledWithError:error];
  }
}

- (void)invalidate {
  for (NSNumber *handle in _handles) {
    [_query removeObserverWithHandle:handle.unsignedIntegerValue];
  }

  [self.handles removeAllObjects];

  // Remove all values on invalidation.
  [self didUpdate];
  for (NSInteger i = 0; i < self.snapshots.count; /* no i++ since we modify the array instead */ ) {
    FIRDataSnapshot *current = self.snapshots[i];

    [self.snapshots removeObjectAtIndex:i];

    [self.keys removeObjectAtIndex:i];
    if ([self.delegate respondsToSelector:@selector(array:didRemoveObject:atIndex:)]) {
      [self.delegate array:self didRemoveObject:current atIndex:i];
    }
  }
  [self didFinishUpdates];
}

- (NSUInteger)indexForKey:(NSString *)key {
  NSParameterAssert(key != nil);
  
  return [self.keys indexOfObject:key];
}

- (void)insertSnapshot:(FIRDataSnapshot *)snap withPreviousChildKey:(NSString *)previous {
  NSUInteger index = 0;
  if (previous != nil) {
    NSInteger previousChildIndex = (NSInteger)[self indexForKey:previous];

    if (previousChildIndex == NSNotFound) {
      NSString *reason = [NSString stringWithFormat:@"Attempted to insert snapshot with unknown"
                          @" previousChildKey %@ into array: %@", previous, self.snapshots];
      NSException *exception = [NSException exceptionWithName:NSInternalInconsistencyException
                                                       reason:reason
                                                     userInfo:nil];
      @throw exception;
    }

    index = previousChildIndex + 1;
  }

  [self.snapshots insertObject:snap atIndex:index];
  [self.keys insertObject:snap.key atIndex:index];

  if ([self.delegate respondsToSelector:@selector(array:didAddObject:atIndex:)]) {
    [self.delegate array:self didAddObject:snap atIndex:index];
  }
}

- (void)removeSnapshot:(FIRDataSnapshot *)snap withPreviousChildKey:(NSString *)previous {
  NSUInteger index = [self indexForKey:snap.key];

  if (index == NSNotFound) {
    NSString *reason = [NSString stringWithFormat:@"Attempted to remove snapshot with unknown"
                        @" key %@ from array: %@", snap.key, self.snapshots];
    NSException *exception = [NSException exceptionWithName:NSInternalInconsistencyException
                                                     reason:reason
                                                   userInfo:nil];
    @throw exception;
  }

  [self.snapshots removeObjectAtIndex:index];
  [self.keys removeObjectAtIndex:index];

  if ([self.delegate respondsToSelector:@selector(array:didRemoveObject:atIndex:)]) {
    [self.delegate array:self didRemoveObject:snap atIndex:index];
  }
}

- (void)changeSnapshot:(FIRDataSnapshot *)snap withPreviousChildKey:(NSString *)previous {
  NSUInteger index = [self indexForKey:snap.key];

  if (index == NSNotFound) {
    NSString *reason = [NSString stringWithFormat:@"Attempted to replace snapshot with unknown"
                        @" key %@ in array: %@", snap.key, self.snapshots];
    NSException *exception = [NSException exceptionWithName:NSInternalInconsistencyException
                                                     reason:reason
                                                   userInfo:nil];
    @throw exception;
  }

  [self.snapshots replaceObjectAtIndex:index withObject:snap];
  [self.keys replaceObjectAtIndex:index withObject:snap.key];

  if ([self.delegate respondsToSelector:@selector(array:didChangeObject:atIndex:)]) {
    [self.delegate array:self didChangeObject:snap atIndex:index];
  }
}

- (void)moveSnapshot:(FIRDataSnapshot *)snap withPreviousChildKey:(NSString *)previous {
  NSUInteger fromIndex = [self indexForKey:snap.key];

  if (fromIndex == NSNotFound) {
    NSString *reason = [NSString stringWithFormat:@"Attempted to remove snapshot with unknown"
                        @" key %@ from array: %@", snap.key, self.snapshots];
    NSException *exception = [NSException exceptionWithName:NSInternalInconsistencyException
                                                     reason:reason
                                                   userInfo:nil];
    @throw exception;
  }

  [self.snapshots removeObjectAtIndex:fromIndex];
  [self.keys removeObjectAtIndex:fromIndex];

  NSUInteger toIndex = 0;
  if (previous != nil) {
    NSUInteger prevIndex = [self indexForKey:previous];
    if (prevIndex != NSNotFound) {
      toIndex = prevIndex + 1;
    }
  }
  [self.snapshots insertObject:snap atIndex:toIndex];
  [self.keys insertObject:snap.key atIndex:toIndex];

  if ([self.delegate respondsToSelector:@selector(array:didMoveObject:fromIndex:toIndex:)]) {
    [self.delegate array:self didMoveObject:snap fromIndex:fromIndex toIndex:toIndex];
  }
}

- (void)removeSnapshotAtIndex:(NSUInteger)index {
  [self.snapshots removeObjectAtIndex:index];
  [self.keys removeObjectAtIndex:index];
}

- (void)insertSnapshot:(FIRDataSnapshot *)snap atIndex:(NSUInteger)index {
  [self.snapshots insertObject:snap atIndex:index];
  [self.keys insertObject:snap.key atIndex:index];
}

- (void)addSnapshot:(FIRDataSnapshot *)snap {
  [self.snapshots addObject:snap];
  [self.keys addObject:snap.key];
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

- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)index {
  @throw [NSException exceptionWithName:@"FUIArraySetIndexWithSubscript"
                                 reason:@"Setting an object as FUIArray[i] is not supported."
                               userInfo:nil];
}

@end
