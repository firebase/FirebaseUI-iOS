//
//  FirebaseArrayTestUtils.m
//  FirebaseUI
//
//  Created by Morgan Chen on 8/8/16.
//  Copyright © 2016 Firebase, Inc. All rights reserved.
//

#import "FirebaseArrayTestUtils.h"

@implementation FUIDataEventHandler
@end

@implementation FUIFakeSnapshot
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

- (void)populateWithCount:(NSUInteger)count generator:(FUIFakeSnapshot *(^)(NSUInteger))generator {
  NSString *previous = nil;
  for (NSUInteger i = 0; i < count; i++) {
    FUIFakeSnapshot *snap = generator(i);
    [self sendEvent:FIRDataEventTypeChildAdded withObject:snap previousKey:previous error:nil];
    previous = snap.key;
  }
}

- (void)populateWithCount:(NSUInteger)count {
  [self populateWithCount:count generator:^FUIFakeSnapshot *(NSUInteger index) {
    FUIFakeSnapshot *snap = [[FUIFakeSnapshot alloc] init];
    snap.key = @(index).stringValue;
    return snap;
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
