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

@interface FirebaseQueryObserver : NSObject

@property (nonatomic, readonly) id<FIRDataObservable> query;
@property (nonatomic, readonly) FIRDataSnapshot *contents;

- (instancetype)initWithQuery:(id<FIRDataObservable>)query;

- (void)removeAllObservers;

@end

@interface FirebaseQueryObserver ()

@property (nonatomic, readonly) NSMutableSet<NSNumber *> *handles;
@property (nonatomic, readwrite) FIRDataSnapshot *contents;

@end

@implementation FirebaseQueryObserver

- (instancetype)initWithQuery:(id<FIRDataObservable>)query {
  self = [super init];
  if (self != nil) {
    _query = query;
    _handles = [NSMutableSet setWithCapacity:4];
  }
  return self;
}

- (void)observeEventType:(FIRDataEventType)eventType
andPreviousSiblingKeyWithBlock:(void (^)(FIRDataSnapshot *snapshot, NSString *__nullable prevKey))block
         withCancelBlock:(nullable void (^)(NSError* error))cancelBlock {
  FIRDatabaseHandle observerHandle = [self.query observeEventType:eventType
                                   andPreviousSiblingKeyWithBlock:block
                                                  withCancelBlock:cancelBlock];
  NSNumber *handle = @(observerHandle);
  if ([self.handles containsObject:handle]) {
    [self.query removeObserverWithHandle:handle.unsignedIntegerValue];
  }
  
  [self.handles addObject:handle];
}

- (void)dealloc {
  [self removeAllObservers];
}

- (void)removeAllObservers {
  for (NSNumber *handle in _handles) {
    [_query removeObserverWithHandle:handle.unsignedIntegerValue];
  }
}

- (BOOL)isEqual:(id)object {
  if (![object isKindOfClass:[self class]]) { return NO; }
  FirebaseQueryObserver *obs = object;
  return [self.query isEqual:obs.query];
}

@end

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

- (instancetype)initWithIndex:(id<FIRDataObservable>)index data:(id<FIRDataObservable>)data {
  NSParameterAssert(index != nil);
  NSParameterAssert(data != nil);
  self = [super init];
  if (self != nil) {
    _index = index;
    _data = data;
    _observers = [NSMutableArray array];
    [self observeQueries];
  }
  return self;
}

- (void)observeQueries {
  _indexArray = [[FirebaseArray alloc] initWithQuery:self.index delegate:self];
}

- (NSArray <FIRDataSnapshot *> *)items {
  NSArray *observers = [self.observers copy];
  NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:observers.count];
  for (FirebaseQueryObserver *observer in observers) {
    [array addObject:observer.contents];
  }
  return [array copy];
}

// FirebaseIndexArray instance becomes unusable after invalidation.
- (void)invalidate {
  for (NSInteger i = 0; i < self.observers.count; i++) {
    FirebaseQueryObserver *observer = self.observers[i];
    [observer removeAllObservers];
  }
  _observers = nil;
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

- (void)array:(FirebaseArray *)array
 didAddObject:(FIRDataSnapshot *)object
      atIndex:(NSUInteger)index {
  NSParameterAssert([object.key isKindOfClass:[NSString class]]);
  NSParameterAssert(object.value != nil);
  id<FIRDataObservable> query = [self.data child:object.key];
  FirebaseQueryObserver *obs = [self observerForQuery:query];
  [self.observers insertObject:obs atIndex:index];
}

- (void)array:(FirebaseArray *)array
didMoveObject:(FIRDataSnapshot *)object
    fromIndex:(NSUInteger)fromIndex
      toIndex:(NSUInteger)toIndex {
  NSParameterAssert([object.value isKindOfClass:[NSString class]]);
  NSParameterAssert(object.value != nil);
  id<FIRDataObservable> query = [self.data child:object.key];
  FirebaseQueryObserver *obs = [self observerForQuery:query];
  [self.observers removeObjectAtIndex:fromIndex];
  [self.observers insertObject:obs atIndex:toIndex];
}

- (void)array:(FirebaseArray *)array
didChangeObject:(FIRDataSnapshot *)object
      atIndex:(NSUInteger)index {
  NSParameterAssert([object.value isKindOfClass:[NSString class]]);
  NSParameterAssert(object.value != nil);
  id<FIRDataObservable> query = [self.data child:object.key];
  FirebaseQueryObserver *obs = [self observerForQuery:query];
  [self.observers replaceObjectAtIndex:index withObject:obs];
}

- (void)array:(FirebaseArray *)array
didRemoveObject:(FIRDataSnapshot *)object
      atIndex:(NSUInteger)index {
  [self.observers[index] removeAllObservers];
  [self.observers removeObjectAtIndex:index];
}

- (void)array:(FirebaseArray *)array queryCancelledWithError:(NSError *)error {
  // TODO: invalidate this array, pass error up somehow
}

- (FirebaseQueryObserver *)observerForQuery:(id<FIRDataObservable>)query {
  FirebaseQueryObserver *obs = [[FirebaseQueryObserver alloc] initWithQuery:query];

  void (^observerBlock)(FIRDataSnapshot *, NSString *) = ^(FIRDataSnapshot *snap,
                                                           NSString *previous) {
    obs.contents = snap;
  };
  void (^cancelBlock)(NSError *) = ^(NSError *error) {
    // TODO: handle errors here
  };

  [obs observeEventType:FIRDataEventTypeChildAdded
    andPreviousSiblingKeyWithBlock:observerBlock withCancelBlock:cancelBlock];
  [obs observeEventType:FIRDataEventTypeValue
    andPreviousSiblingKeyWithBlock:observerBlock withCancelBlock:cancelBlock];
  return obs;
}

@end
