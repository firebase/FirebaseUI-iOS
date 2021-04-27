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

#import "FirebaseDatabaseUI/Sources/Public/FirebaseDatabaseUI/FUIIndexArray.h"
#import "FirebaseDatabaseUI/Sources/Public/FirebaseDatabaseUI/FUIQueryObserver.h"

@interface FUIIndexArray () <FUICollectionDelegate>

@property (nonatomic, readonly) id<FUIDataObservable> index;
@property (nonatomic, readonly) id<FUIDataObservable> data;

@property (nonatomic, readonly) FUIArray *indexArray;

@property (nonatomic, readonly) NSMutableArray<FUIQueryObserver *> *observers;

@end

/**
 * FUIIndexArray manages an instance of FirebaseArray internally to
 * keep track of which queries it should be updating. The FirebaseArrayDelegate
 * methods are responsible for keeping observers up-to-date as the contents of
 * the FirebaseArray change.
 */
@implementation FUIIndexArray

- (instancetype)init {
  NSException *e =
    [NSException exceptionWithName:@"FIRUnavailableMethodException"
                            reason:@"-init is unavailable. Please use the designated initializer instead."
                          userInfo:nil];
  @throw e;
}

- (instancetype)initWithIndex:(id<FUIDataObservable>)index
                         data:(id<FUIDataObservable>)data
                     delegate:(nullable id<FUIIndexArrayDelegate>)delegate; {
  NSParameterAssert(index != nil);
  NSParameterAssert(data != nil);
  self = [super init];
  if (self != nil) {
    _index = index;
    _data = data;
    _observers = [NSMutableArray array];
    _delegate = delegate;
  }
  return self;
}

- (instancetype)initWithIndex:(id<FUIDataObservable>)index
                         data:(id<FUIDataObservable>)data {
  return [self initWithIndex:index data:data delegate:nil];
}

- (void)observeQueries {
  _indexArray = [[FUIArray alloc] initWithQuery:self.index delegate:self];
  [_indexArray observeQuery];
}

- (NSArray<FIRDataSnapshot *> *)items {
  NSArray *observers = [self.observers copy];
  NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:observers.count];
  for (FUIQueryObserver *observer in observers) {
    if (observer.contents != nil) {
      [array addObject:observer.contents];
    }
  }
  return [array copy];
}

- (NSArray<FIRDataSnapshot *> *) indexes {
  return self.indexArray.items;
}

- (NSUInteger)count {
  return self.observers.count;
}

- (void)observeQuery {
  [self observeQueries];
}

// FUIIndexArray instance becomes unusable after invalidation.
- (void)invalidate {
  for (NSInteger i = 0; i < self.observers.count; i++) {
    FUIQueryObserver *observer = self.observers[i];
    [observer removeAllObservers];
  }
  _observers = nil;
}

- (FIRDataSnapshot *)objectAtIndex:(NSUInteger)index {
  return self.observers[index].contents;
}

- (void)dealloc {
  [self invalidate];
}

#pragma mark - FirebaseArrayDelegate

- (void)observer:(FUIQueryObserver *)obs
didFinishLoadWithSnap:(FIRDataSnapshot *)snap
           error:(NSError *)error {
  // Need to look up location in array to account for possible moves
  NSUInteger index = [self.observers indexOfObject:obs];

  if (error != nil) {
    if ([self.delegate respondsToSelector:@selector(array:reference:atIndex:didFailLoadWithError:)]) {
      [self.delegate array:self reference:obs.query atIndex:index didFailLoadWithError:error];
    }
    return;
  }

  if ([self.delegate respondsToSelector:@selector(array:reference:didLoadObject:atIndex:)]) {
    [self.delegate array:self reference:obs.query didLoadObject:snap atIndex:index];
  }
}

- (void)array:(FUIArray *)array
 didAddObject:(FIRDataSnapshot *)object
      atIndex:(NSUInteger)index {
  NSParameterAssert([object.key isKindOfClass:[NSString class]]);
  id<FUIDataObservable> query = [self.data child:object.key];
  __weak typeof(self) wSelf = self;
  FUIQueryObserver *obs = [FUIQueryObserver observerForQuery:query
                                                            completion:^(FUIQueryObserver *observer,
                                                                         FIRDataSnapshot *snap,
                                                                         NSError *error) {
    [wSelf observer:observer didFinishLoadWithSnap:snap error:error];
  }];
  [self.observers insertObject:obs atIndex:index];

  if ([self.delegate respondsToSelector:@selector(array:didAddReference:atIndex:)]) {
    [self.delegate array:self didAddReference:query atIndex:index];
  }
}

- (void)array:(FUIArray *)array
didMoveObject:(FIRDataSnapshot *)object
    fromIndex:(NSUInteger)fromIndex
      toIndex:(NSUInteger)toIndex {
  NSParameterAssert([object.key isKindOfClass:[NSString class]]);
  FUIQueryObserver *obs = self.observers[fromIndex];

  [self.observers removeObjectAtIndex:fromIndex];
  [self.observers insertObject:obs atIndex:toIndex];

  if ([self.delegate respondsToSelector:@selector(array:didMoveReference:fromIndex:toIndex:)]) {
    [self.delegate array:self didMoveReference:obs.query fromIndex:fromIndex toIndex:toIndex];
  }
}

- (void)array:(FUIArray *)array
didChangeObject:(FIRDataSnapshot *)object
      atIndex:(NSUInteger)index {
  NSParameterAssert([object.key isKindOfClass:[NSString class]]);

  // Cancel any active loads on the old observer
  [self.observers[index] removeAllObservers];

  // Add new observer
  __weak typeof(self) wSelf = self;
  id<FUIDataObservable> query = [self.data child:object.key];
  FUIQueryObserver *obs = [FUIQueryObserver observerForQuery:query
                                                            completion:^(FUIQueryObserver *observer,
                                                                         FIRDataSnapshot *snap,
                                                                         NSError *error) {
    [wSelf observer:observer didFinishLoadWithSnap:snap error:error];
  }];
  [self.observers replaceObjectAtIndex:index withObject:obs];

  if ([self.delegate respondsToSelector:@selector(array:didChangeReference:atIndex:)]) {
    [self.delegate array:self didChangeReference:query atIndex:index];
  }
}

- (void)array:(FUIArray *)array
didRemoveObject:(FIRDataSnapshot *)object
      atIndex:(NSUInteger)index {
  // Cancel loads on old observer
  [self.observers[index] removeAllObservers];

  [self.observers removeObjectAtIndex:index];

  id<FUIDataObservable> query = [self.data child:object.key];
  if ([self.delegate respondsToSelector:@selector(array:didRemoveReference:atIndex:)]) {
    [self.delegate array:self didRemoveReference:query atIndex:index];
  }
}

- (void)array:(FUIArray *)array queryCancelledWithError:(NSError *)error {
  [self invalidate];
  if ([self.delegate respondsToSelector:@selector(array:queryCancelledWithError:)]) {
    [self.delegate array:self queryCancelledWithError:error];
  }
}

@end
