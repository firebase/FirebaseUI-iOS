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

#import "FirebaseIndexArray.h"
#import "FirebaseQueryObserver.h"

@interface FirebaseIndexArray () <FirebaseArrayDelegate>

@property (nonatomic, readonly) id<FIRDataObservable> index;
@property (nonatomic, readonly) id<FIRDataObservable> data;

@property (nonatomic, readonly) FirebaseArray *indexArray;

@property (nonatomic, readonly) NSMutableArray<FirebaseQueryObserver *> *observers;

@end

@implementation FirebaseIndexArray

- (instancetype)init {
  NSException *e =
    [NSException exceptionWithName:@"FIRUnavailableMethodException"
                            reason:@"-init is unavailable. Please use the designated initializer instead."
                          userInfo:nil];
  @throw e;
}

- (instancetype)initWithIndex:(id<FIRDataObservable>)index
                         data:(id<FIRDataObservable>)data
                     delegate:(nullable id<FirebaseIndexArrayDelegate>)delegate; {
  NSParameterAssert(index != nil);
  NSParameterAssert(data != nil);
  self = [super init];
  if (self != nil) {
    _index = index;
    _data = data;
    _observers = [NSMutableArray array];
    _delegate = delegate;
    [self observeQueries];
  }
  return self;
}

- (instancetype)initWithIndex:(id<FIRDataObservable>)index
                         data:(id<FIRDataObservable>)data {
  return [self initWithIndex:index data:data delegate:nil];
}

- (void)observeQueries {
  _indexArray = [[FirebaseArray alloc] initWithQuery:self.index delegate:self];
}

- (NSArray <FIRDataSnapshot *> *)items {
  NSArray *observers = [self.observers copy];
  NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:observers.count];
  for (FirebaseQueryObserver *observer in observers) {
    if (observer.contents != nil) {
      [array addObject:observer.contents];
    }
  }
  return [array copy];
}

- (NSUInteger)count {
  return self.observers.count;
}

// FirebaseIndexArray instance becomes unusable after invalidation.
- (void)invalidate {
  for (NSInteger i = 0; i < self.observers.count; i++) {
    FirebaseQueryObserver *observer = self.observers[i];
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

// These delegate methods are entirely responsible
// for keeping a local array of queries up to date.
// Like mapping a FirebaseArray's contents, except
// they must be kept up to date as the FirebaseArray
// changes over time.

- (void)observer:(FirebaseQueryObserver *)obs
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

- (void)array:(FirebaseArray *)array
 didAddObject:(FIRDataSnapshot *)object
      atIndex:(NSUInteger)index {
  NSParameterAssert([object.key isKindOfClass:[NSString class]]);
  id<FIRDataObservable> query = [self.data child:object.key];
  FirebaseQueryObserver *obs = [FirebaseQueryObserver observerForQuery:query
                                                            completion:^(FirebaseQueryObserver *observer,
                                                                         FIRDataSnapshot *snap,
                                                                         NSError *error) {
    [self observer:observer didFinishLoadWithSnap:snap error:error];
  }];
  [self.observers insertObject:obs atIndex:index];

  if ([self.delegate respondsToSelector:@selector(array:didAddReference:atIndex:)]) {
    [self.delegate array:self didAddReference:query atIndex:index];
  }
}

- (void)array:(FirebaseArray *)array
didMoveObject:(FIRDataSnapshot *)object
    fromIndex:(NSUInteger)fromIndex
      toIndex:(NSUInteger)toIndex {
  NSParameterAssert([object.key isKindOfClass:[NSString class]]);
  FirebaseQueryObserver *obs = self.observers[fromIndex];

  [self.observers removeObjectAtIndex:fromIndex];
  [self.observers insertObject:obs atIndex:toIndex];

  if ([self.delegate respondsToSelector:@selector(array:didMoveReference:fromIndex:toIndex:)]) {
    [self.delegate array:self didMoveReference:obs.query fromIndex:fromIndex toIndex:toIndex];
  }
}

- (void)array:(FirebaseArray *)array
didChangeObject:(FIRDataSnapshot *)object
      atIndex:(NSUInteger)index {
  NSParameterAssert([object.key isKindOfClass:[NSString class]]);

  // Cancel any active loads on the old observer
  [self.observers[index] removeAllObservers];

  // Add new observer
  id<FIRDataObservable> query = [self.data child:object.key];
  FirebaseQueryObserver *obs = [FirebaseQueryObserver observerForQuery:query
                                                            completion:^(FirebaseQueryObserver *observer,
                                                                         FIRDataSnapshot *snap,
                                                                         NSError *error) {
    [self observer:observer didFinishLoadWithSnap:snap error:error];
  }];
  [self.observers replaceObjectAtIndex:index withObject:obs];

  if ([self.delegate respondsToSelector:@selector(array:didChangeReference:atIndex:)]) {
    [self.delegate array:self didChangeReference:query atIndex:index];
  }
}

- (void)array:(FirebaseArray *)array
didRemoveObject:(FIRDataSnapshot *)object
      atIndex:(NSUInteger)index {
  // Cancel loads on old observer
  [self.observers[index] removeAllObservers];

  [self.observers removeObjectAtIndex:index];

  id<FIRDataObservable> query = [self.data child:object.key];
  if ([self.delegate respondsToSelector:@selector(array:didRemoveReference:atIndex:)]) {
    [self.delegate array:self didRemoveReference:query atIndex:index];
  }
}

- (void)array:(FirebaseArray *)array queryCancelledWithError:(NSError *)error {
  [self invalidate];
  if ([self.delegate respondsToSelector:@selector(array:queryCancelledWithError:)]) {
    [self.delegate array:self queryCancelledWithError:error];
  }
}

@end
