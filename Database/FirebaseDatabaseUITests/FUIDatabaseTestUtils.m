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

#import "FUIDatabaseTestUtils.h"

@import Foundation;

@implementation FUIDataEventHandler
@end

@implementation FUIFakeSnapshot
- (instancetype)initWithKey:(NSString *)key value:(id)value {
  self = [super init];
  if (self != nil) {
    _key = [key copy];
    _value = [value copy];
  }
  return self;
}

+ (instancetype)snapWithKey:(NSString *)key value:(id)value {
  return [[self alloc] initWithKey:key value:value];
}

- (BOOL)isEqual:(id)object {
  if (![object isKindOfClass:[FUIFakeSnapshot class]] &&
      ![object isKindOfClass:[FIRDataSnapshot class]]) {
    return NO;
  }
  FUIFakeSnapshot *snap = object;
  return [snap.key isEqualToString:self.key] && [snap.value isEqual:self.value];
}

- (NSString *)description {
  return [NSString stringWithFormat:@"<FUIFakeSnapshot: %p key = %@, value = %@>", self, self.key, self.value];
}
@end

@interface FUITestObservable ()
@property (nonatomic, readonly) NSMutableArray<NSString *> *keys;
@property (nonatomic, readonly) NSMutableDictionary<NSString *, id> *contents;
@end

@implementation FUITestObservable

- (instancetype)init {
  return [self initWithDictionary:@{}];
}

- (instancetype)initWithDictionary:(NSDictionary *)contents {
  self = [super init];
  if (self != nil) {
    _contents = [contents mutableCopy];
    _keys = [contents.allKeys mutableCopy];
    _observers = [NSMutableDictionary dictionary];
  }
  return self;
}

- (void)addObject:(id)object forKey:(NSString *)key {
  [self.keys addObject:key];
  self.contents[key] = object;

  FUIFakeSnapshot *snap = [[FUIFakeSnapshot alloc] initWithKey:key value:object];
  NSString *previousKey = nil;
  if (self.keys.count > 1) {
    previousKey = self.keys[self.keys.count - 2];
  }
  [self sendEvent:FIRDataEventTypeChildAdded withObject:snap previousKey:previousKey error:nil];
}

- (void)removeObjectForKey:(NSString *)key {
  id value = self.contents[key];
  FUIFakeSnapshot *snap = [[FUIFakeSnapshot alloc] initWithKey:key value:value];

  NSString *previousKey = nil;
  NSUInteger i = [self.keys indexOfObject:key];
  if (i == NSNotFound) return;
  if (i > 0) {
    previousKey = self.keys[i - 1];
  }

  [self.keys removeObject:key];
  [self.contents removeObjectForKey:key];

  [self sendEvent:FIRDataEventTypeChildRemoved withObject:snap previousKey:previousKey error:nil];
}

- (void)moveObjectFromIndex:(NSUInteger)from toIndex:(NSUInteger)to {
  NSString *key = self.keys[from];
  id value = self.contents[key];
  FUIFakeSnapshot *snap = [[FUIFakeSnapshot alloc] initWithKey:key value:value];

  if (from > to) {
    [self.keys removeObjectAtIndex:from];
    [self.keys insertObject:key atIndex:to];
  } else if (to > from) {
    [self.keys removeObjectAtIndex:from];
    [self.keys insertObject:key atIndex:to];
  }

  NSString *previousKey = nil;
  NSUInteger i = [self.keys indexOfObject:key];
  if (i == NSNotFound) return;
  if (i > 0) {
    previousKey = self.keys[i - 1];
  }

  [self sendEvent:FIRDataEventTypeChildMoved withObject:snap previousKey:previousKey error:nil];
}

- (void)changeObject:(id)object forKey:(NSString *)key {
  FUIFakeSnapshot *snap = [[FUIFakeSnapshot alloc] initWithKey:key value:object];

  self.contents[key] = object;

  NSString *previousKey = nil;
  NSUInteger i = [self.keys indexOfObject:key];
  if (i == NSNotFound) return;
  if (i > 0) {
    previousKey = self.keys[i - 1];
  }

  [self sendEvent:FIRDataEventTypeChildChanged withObject:snap previousKey:previousKey error:nil];
}

- (void)removeObserverWithHandle:(FIRDatabaseHandle)handle {
  [self.observers removeObjectForKey:@(handle)];
}

- (id<FUIDataObservable>)child:(NSString *)path {
  if (self.contents[path] == nil) { return nil; }
  NSParameterAssert([self.contents[path] isKindOfClass:[NSDictionary class]]);
  NSDictionary *subdict = self.contents[path];
  return [[FUITestObservable alloc] initWithDictionary:subdict];
}

- (void)removeAllObservers {
  _observers = [NSMutableDictionary dictionary];
}

- (FIRDatabaseHandle)observeEventType:(FIRDataEventType)eventType
       andPreviousSiblingKeyWithBlock:(void (^)(FIRDataSnapshot *_Nonnull, NSString *_Nullable))block
                      withCancelBlock:(void (^)(NSError *_Nonnull))cancelBlock  {
  FUIDataEventHandler *handler = [[FUIDataEventHandler alloc] init];
  handler.event = eventType;
  handler.success = block;
  handler.cancelled = cancelBlock;
  
  NSNumber *key = @(self.current);
  _current++;
  self.observers[key] = handler;

  // Send values on first observation
  if (self.observers.count == 1) {
    NSArray *allKeys = self.contents.allKeys;
    id previousKey = nil;
    for (id contentKey in allKeys) {
      id value = self.contents[contentKey];
      FUIFakeSnapshot *snap = [[FUIFakeSnapshot alloc] initWithKey:contentKey value:value];
      [self sendEvent:FIRDataEventTypeChildAdded withObject:snap previousKey:previousKey error:nil];

      // Send a value event, since this is a complete snapshot.
      // TODO: FUIFakeSnapshot currently only represents dictionary types, though snapshots can
      // have array, string, or number values as well. Tests need to be written for these.
      [self sendEvent:FIRDataEventTypeValue withObject:snap previousKey:previousKey error:nil];
      previousKey = contentKey;
    }
  }

  return key.unsignedIntegerValue;
}

- (void)sendEvent:(FIRDataEventType)event
       withObject:(FUIFakeSnapshot *)object
      previousKey:(NSString *)string
            error:(NSError *)error {
  NSArray *allKeys = self.observers.allKeys;
  for (NSNumber *key in allKeys) {
    FUIDataEventHandler *handler = self.observers[key];
    if (handler.event == event) {
      if (error != nil) { handler.cancelled(error); }
      else { handler.success((FIRDataSnapshot *)object, string); }
    }
  }
}

- (void)populateWithCount:(NSUInteger)count generator:(NSString *(^)(NSUInteger))generator {
  NSString *previous = nil;
  for (NSUInteger i = 0; i < count; i++) {
    FUIFakeSnapshot *snap = [[FUIFakeSnapshot alloc] init];
    snap.value = generator(i);
    snap.key = @(i).stringValue;
    [self sendEvent:FIRDataEventTypeChildAdded withObject:snap previousKey:previous error:nil];
    previous = snap.key;
  }
}

- (void)populateWithCount:(NSUInteger)count {
  [self populateWithCount:count generator:^NSString *(NSUInteger index) {
    return @(index).stringValue;
  }];
}

@end

@implementation FUIArrayTestDelegate

- (void)arrayDidBeginUpdates:(id<FUICollection>)collection {
  if (self.didStartUpdates != NULL) {
    self.didStartUpdates();
  }
}

- (void)arrayDidEndUpdates:(id<FUICollection>)collection {
  if (self.didEndUpdates != NULL) {
    self.didEndUpdates();
  }
}

- (void)array:(id<FUICollection>)array didAddObject:(id)object atIndex:(NSUInteger)index {
  if (self.didAddObject != NULL) {
    self.didAddObject(array, object, index);
  }
}

- (void)array:(id<FUICollection>)array didChangeObject:(id)object atIndex:(NSUInteger)index {
  if (self.didChangeObject != NULL) {
    self.didChangeObject(array, object, index);
  }
}

- (void)array:(id<FUICollection>)array didRemoveObject:(id)object atIndex:(NSUInteger)index {
  if (self.didRemoveObject != NULL) {
    self.didRemoveObject(array, object, index);
  }
}

- (void)array:(id<FUICollection>)array didMoveObject:(id)object
    fromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
  if (self.didMoveObject != NULL) {
    self.didMoveObject(array, object, fromIndex, toIndex);
  }
}

- (void)array:(FUIArray *)array queryCancelledWithError:(NSError *)error {
  if (self.queryCancelled != NULL) {
    self.queryCancelled(array, error);
  }
}

@end

@implementation FUIIndexArrayTestDelegate

- (void)array:(FUIIndexArray *)array
    reference:(nonnull FIRDatabaseReference *)ref
didLoadObject:(nonnull FIRDataSnapshot *)object
      atIndex:(NSUInteger)index {
  if (self.didLoad != NULL) {
    self.didLoad(array, ref, object, index);
  }
}

- (void)array:(FUIIndexArray *)array reference:(nonnull FIRDatabaseReference *)ref
      atIndex:(NSUInteger)index didFailLoadWithError:(nonnull NSError *)error {
  if (self.didFail != NULL) {
    self.didFail(array, ref, index, error);
  }
}

- (void)array:(FUIIndexArray *)array didAddReference:(nonnull FIRDatabaseReference *)ref
      atIndex:(NSUInteger)index {
  if (self.didAddQuery != NULL) {
    self.didAddQuery(array, ref, index);
  }
}

- (void)array:(FUIIndexArray *)array didChangeReference:(nonnull FIRDatabaseReference *)ref
      atIndex:(NSUInteger)index {
  if (self.didChangeQuery != NULL) {
    self.didChangeQuery(array, ref, index);
  }
}

- (void)array:(FUIIndexArray *)array didRemoveReference:(nonnull FIRDatabaseReference *)ref
      atIndex:(NSUInteger)index {
  if (self.didRemoveQuery != nil) {
    self.didRemoveQuery(array, ref, index);
  }
}

- (void)array:(FUIIndexArray *)array didMoveReference:(nonnull FIRDatabaseReference *)ref
    fromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
  if (self.didMoveQuery != NULL) {
    self.didMoveQuery(array, ref, fromIndex, toIndex);
  }
}

@end
