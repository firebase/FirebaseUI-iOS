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

@import XCTest;

#import "FirebaseArray.h"

// Dumb object holding a pair of blocks and a data event type.
@interface FUIDataEventHandler: NSObject
@property (nonatomic, assign) FIRDataEventType event;
@property (nonatomic, copy, nonnull) void (^success)(FIRDataSnapshot * _Nonnull, NSString *_Nullable);
@property (nonatomic, copy, nonnull) void (^cancelled)(NSError *_Nonnull);
@end
@implementation FUIDataEventHandler
@end

// A dummy observable so we can test this without relying on an internet connection.
@interface FUITestObservable: NSObject <FIRDataObservable>

// Map of handles to observers.
@property (nonatomic, readonly) NSMutableDictionary<NSNumber *, FUIDataEventHandler *> *observers;

// Incremented to generate unique handles.
@property (nonatomic, readonly, assign) FIRDatabaseHandle current;

@end

// Horrible abuse of ObjC type system, since FirebaseArray is unfortunately coupled to
// FIRDataSnapshot
@interface FUIFakeSnapshot: NSObject
@property (nonatomic, assign) NSString *key;
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

// Sends an event in jankiest possible way
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

// Sends a bunch of insertion events with snapshot keys as integer strings (i.e. @"0") of increasing
// order, starting from 0.
- (void)populateWithCount:(NSUInteger)count {
  NSString *previous = nil;
  for (NSUInteger i = 0; i < count; i++) {
    FUIFakeSnapshot *snap = [[FUIFakeSnapshot alloc] init];
    snap.key = @(i).stringValue;
    [self sendEvent:FIRDataEventTypeChildAdded withObject:snap previousKey:previous error:nil];
    previous = snap.key;
  }
}

@end

@interface FirebaseArrayTest : XCTestCase

@property (nonatomic, nullable) FUITestObservable *observable;
@property (nonatomic, nullable) FirebaseArray *firebaseArray;

@end

@implementation FirebaseArrayTest

- (void)setUp {
  [super setUp];
  self.observable = [[FUITestObservable alloc] init];
  self.firebaseArray = [[FirebaseArray alloc] initWithQuery:self.observable];
}

- (void)tearDown {
  [super tearDown];
  [self.observable removeAllObservers];
}

- (void)testFirebaseArrayCanBeInitialized {
  XCTAssertNotNil(self.observable, @"expected FirebaseArray to not be nil when initialized");
}

- (void)testEmptyFirebaseArrayUpdatesCountOnInsert {
  FUIFakeSnapshot *snap = [[FUIFakeSnapshot alloc] init];
  snap.key = @"snapshot";
  [self.observable sendEvent:FIRDataEventTypeChildAdded
                  withObject:snap
                 previousKey:nil
                       error:nil];
  NSAssert(self.firebaseArray.count == 1, @"expected empty array to contain one item after insert");
}

- (void)testFirebaseArrayCanDeleteOneElementArray {
  // Insert a key
  FUIFakeSnapshot *snap = [[FUIFakeSnapshot alloc] init];
  snap.key = @"snapshot";
  [self.observable sendEvent:FIRDataEventTypeChildAdded
                  withObject:snap
                 previousKey:nil
                       error:nil];
  
  // Delete
  [self.observable sendEvent:FIRDataEventTypeChildRemoved
                  withObject:snap
                 previousKey:nil
                       error:nil];
  
  XCTAssert(self.firebaseArray.count == 0,
            @"expected empty array to still be empty after one insertion and one deletion");
}

- (void)testFirebaseArrayCanInsertInMiddle {
  // Setup boilerplate
  [self.observable populateWithCount:10];
  FUIFakeSnapshot *snap = [[FUIFakeSnapshot alloc] init];
  snap.key = @"5";
  
  // This is the actual change being tested
  [self.observable sendEvent:FIRDataEventTypeChildAdded withObject:snap previousKey:@"4" error:nil];
  
  // Expectation boilerplate
  NSArray *items = self.firebaseArray.items;
  NSArray *expected = @[@"0", @"1", @"2", @"3", @"4", @"5", @"5", @"6", @"7", @"8", @"9"];
  NSMutableArray *result = [NSMutableArray array];
  for (FUIFakeSnapshot *snapshot in items) {
    [result addObject:snapshot.key];
  }
  
  XCTAssert([result isEqual:expected], @"expected firebaseArray contents to equal %@, got %@", expected, [result copy]);
}

@end
