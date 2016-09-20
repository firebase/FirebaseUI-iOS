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

#import "FirebaseArray.h"

@interface FirebaseArray ()

/**
 * The backing collection that holds all of the FirebaseArray's data.
 */
@property(strong, nonatomic) NSMutableArray<FIRDataSnapshot *> *snapshots;

/**
 * A set containing the query observer handles that should be released when
 * this array is freed.
 */
@property(strong, nonatomic) NSMutableSet<NSNumber *> *handles;

@end

@implementation FirebaseArray

#pragma mark - Initializer methods

- (instancetype)initWithQuery:(FIRDatabaseQuery *)query delegate:(id<FirebaseArrayDelegate>)delegate {
  NSParameterAssert(query != nil);
  self = [super init];
  if (self) {
    self.snapshots = [NSMutableArray array];
    self.query = query;
    self.handles = [NSMutableSet setWithCapacity:4];
    self.delegate = delegate;
    [self initListeners];
  }
  return self;
}

- (instancetype)initWithQuery:(id<FIRDataObservable>)query {
  return [self initWithQuery:query delegate:nil];
}

+ (instancetype)arrayWithQuery:(id<FIRDataObservable>)query {
  return [[self alloc] initWithQuery:query];
}

#pragma mark - Memory management methods

- (void)dealloc {
  for (NSNumber *handle in _handles) {
    [_query removeObserverWithHandle:handle.unsignedIntegerValue];
  }
}

#pragma mark - Private API methods

- (void)initListeners {
  FIRDatabaseHandle handle;
  handle = [self.query observeEventType:FIRDataEventTypeChildAdded
      andPreviousSiblingKeyWithBlock:^(FIRDataSnapshot *snapshot, NSString *previousChildKey) {
        NSUInteger index = 0;
        if (previousChildKey != nil) {
          index = [self indexForKey:previousChildKey] + 1;
        }

        [self.snapshots insertObject:snapshot atIndex:index];

        if ([self.delegate respondsToSelector:@selector(array:didAddObject:atIndex:)]) {
          [self.delegate array:self didAddObject:snapshot atIndex:index];
        }
      }
      withCancelBlock:^(NSError *error) {
        if ([self.delegate respondsToSelector:@selector(array:queryCancelledWithError:)]) {
          [self.delegate array:self queryCancelledWithError:error];
        }
      }];
  [_handles addObject:@(handle)];

  handle = [self.query observeEventType:FIRDataEventTypeChildChanged
      andPreviousSiblingKeyWithBlock:^(FIRDataSnapshot *snapshot, NSString *previousChildKey) {
        NSUInteger index = [self indexForKey:snapshot.key];

        [self.snapshots replaceObjectAtIndex:index withObject:snapshot];

        if ([self.delegate respondsToSelector:@selector(array:didChangeObject:atIndex:)]) {
          [self.delegate array:self didChangeObject:snapshot atIndex:index];
        }
      }
      withCancelBlock:^(NSError *error) {
        if ([self.delegate respondsToSelector:@selector(array:queryCancelledWithError:)]) {
          [self.delegate array:self queryCancelledWithError:error];
        }
      }];
  [_handles addObject:@(handle)];

  handle = [self.query observeEventType:FIRDataEventTypeChildRemoved
      andPreviousSiblingKeyWithBlock:^(FIRDataSnapshot *snapshot, NSString *previousSiblingKey) {
        NSUInteger index = [self indexForKey:snapshot.key];

        [self.snapshots removeObjectAtIndex:index];

        if ([self.delegate respondsToSelector:@selector(array:didRemoveObject:atIndex:)]) {
          [self.delegate array:self didRemoveObject:snapshot atIndex:index];
        }
      }
      withCancelBlock:^(NSError *error) {
        if ([self.delegate respondsToSelector:@selector(array:queryCancelledWithError:)]) {
          [self.delegate array:self queryCancelledWithError:error];
        }
      }];
  [_handles addObject:@(handle)];

  handle = [self.query observeEventType:FIRDataEventTypeChildMoved
      andPreviousSiblingKeyWithBlock:^(FIRDataSnapshot *snapshot, NSString *previousChildKey) {
        NSUInteger fromIndex = [self indexForKey:snapshot.key];
        [self.snapshots removeObjectAtIndex:fromIndex];

        NSUInteger toIndex = [self indexForKey:previousChildKey] + 1;
        [self.snapshots insertObject:snapshot atIndex:toIndex];

        if ([self.delegate respondsToSelector:@selector(array:didMoveObject:fromIndex:toIndex:)]) {
          [self.delegate array:self didMoveObject:snapshot fromIndex:fromIndex toIndex:toIndex];
        }
      }
      withCancelBlock:^(NSError *error) {
        if ([self.delegate respondsToSelector:@selector(array:queryCancelledWithError:)]) {
          [self.delegate array:self queryCancelledWithError:error];
        }
      }];
  [_handles addObject:@(handle)];
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

#pragma mark - Public API methods

- (NSArray *)items {
  return [self.snapshots copy];
}

- (NSUInteger)count {
  return [self.snapshots count];
}

- (FIRDataSnapshot *)objectAtIndex:(NSUInteger)index {
  return (FIRDataSnapshot *)[self.snapshots objectAtIndex:index];
}

- (FIRDatabaseReference *)refForIndex:(NSUInteger)index {
  return [(FIRDataSnapshot *)[self.snapshots objectAtIndex:index] ref];
}

- (id)objectAtIndexedSubscript:(NSUInteger)index {
  return [self objectAtIndex:index];
}

- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)index{
  @throw [NSException exceptionWithName:@"FirebaseArraySetIndexWithSubscript"
                                 reason:@"Setting an object as FirebaseArray[i] is not supported."
                               userInfo:nil];
}

@end
