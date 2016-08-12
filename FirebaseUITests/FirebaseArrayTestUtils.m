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

#import "FirebaseArrayTestUtils.h"

@implementation FUIDataEventHandler
@end

@implementation FUIFakeSnapshot
- (instancetype)initWithKey:(NSString *)key value:(NSString *)value {
  self = [super init];
  if (self != nil) {
    _key = [key copy];
    _value = [value copy];
  }
  return self;
}
@end

@implementation FUITestObservable

- (instancetype)init {
  self = [super init];
  if (self != nil) {
    _observers = [NSMutableDictionary dictionary];
  }
  return self;
}

- (void)removeObserverWithHandle:(FIRDatabaseHandle)handle {
  [self.observers removeObjectForKey:@(handle)];
}

- (void)removeAllObservers {
  _observers = [NSMutableDictionary dictionary];
}

- (FIRDatabaseHandle)observeEventType:(FIRDataEventType)eventType
       andPreviousSiblingKeyWithBlock:(void (^)(FIRDataSnapshot * _Nonnull, NSString * _Nullable))block
                      withCancelBlock:(void (^)(NSError * _Nonnull))cancelBlock  {
  FUIDataEventHandler *handler = [[FUIDataEventHandler alloc] init];
  handler.event = eventType;
  handler.success = block;
  handler.cancelled = cancelBlock;
  
  NSNumber *key = @(self.current);
  _current++;
  self.observers[key] = handler;
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

@implementation FUIFirebaseArrayTestDelegate

- (void)array:(FirebaseArray *)array didAddObject:(id)object atIndex:(NSUInteger)index {
  if (self.didAddObject != NULL) {
    self.didAddObject(array, object, index);
  }
}

- (void)array:(FirebaseArray *)array didChangeObject:(id)object atIndex:(NSUInteger)index {
  if (self.didChangeObject != NULL) {
    self.didChangeObject(array, object, index);
  }
}

- (void)array:(FirebaseArray *)array didRemoveObject:(id)object atIndex:(NSUInteger)index {
  if (self.didRemoveObject != NULL) {
    self.didRemoveObject(array, object, index);
  }
}

- (void)array:(FirebaseArray *)array didMoveObject:(id)object
    fromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
  if (self.didMoveObject != NULL) {
    self.didMoveObject(array, object, fromIndex, toIndex);
  }
}

- (void)array:(FirebaseArray *)array queryCancelledWithError:(NSError *)error {
  if (self.queryCancelled != NULL) {
    self.queryCancelled(array, error);
  }
}

@end
