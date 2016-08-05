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
@property (nonatomic, copy, nonnull) void (^success)(FIRDataSnapshot *_Nonnull, NSString *_Nullable);
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

// Inserts sequentially with data provided by the `generator` block.
- (void)populateWithCount:(NSUInteger)count generator:(FUIFakeSnapshot *(^)(NSUInteger))generator {
  NSString *previous = nil;
  for (NSUInteger i = 0; i < count; i++) {
    FUIFakeSnapshot *snap = generator(i);
    [self sendEvent:FIRDataEventTypeChildAdded withObject:snap previousKey:previous error:nil];
    previous = snap.key;
  }
}

// Sends a bunch of insertion events with snapshot keys as integer strings (i.e. @"0") of increasing
// order, starting from 0.
- (void)populateWithCount:(NSUInteger)count {
  [self populateWithCount:count generator:^FUIFakeSnapshot *(NSUInteger index) {
    FUIFakeSnapshot *snap = [[FUIFakeSnapshot alloc] init];
    snap.key = @(index).stringValue;
    return snap;
  }];
}

@end

@interface FirebaseArrayTest : XCTestCase

@property (nonatomic, nullable) FUITestObservable *observable;
@property (nonatomic, nullable) FirebaseArray *firebaseArray;
@property (nonatomic, nullable) FUIFakeSnapshot *snap;

@end

@implementation FirebaseArrayTest

- (void)setUp {
  [super setUp];
  self.snap = [[FUIFakeSnapshot alloc] init];
  self.observable = [[FUITestObservable alloc] init];
  self.firebaseArray = [[FirebaseArray alloc] initWithQuery:self.observable];
}

- (void)tearDown {
  [super tearDown];
  [self.observable removeAllObservers];
}

#pragma mark - Insertion

- (void)testFirebaseArrayCanBeInitialized {
  XCTAssertNotNil(self.firebaseArray, @"expected FirebaseArray to not be nil when initialized");
}

- (void)testEmptyFirebaseArrayUpdatesCountOnInsert {
  self.snap.key = @"snapshot";
  [self.observable sendEvent:FIRDataEventTypeChildAdded
                  withObject:self.snap
                 previousKey:nil
                       error:nil];
  NSAssert(self.firebaseArray.count == 1, @"expected empty array to contain one item after insert");
}

- (void)testFirebaseArrayCanInsertInMiddle {
  // Setup boilerplate
  [self.observable populateWithCount:10];
  self.snap.key = @"5";
  
  // Insert in middle
  [self.observable sendEvent:FIRDataEventTypeChildAdded withObject:self.snap previousKey:@"4" error:nil];
  
  // Expectation boilerplate
  NSArray *items = self.firebaseArray.items;
  NSArray *expected = @[@"0", @"1", @"2", @"3", @"4", @"5", @"5", @"6", @"7", @"8", @"9"];
  NSMutableArray *result = [NSMutableArray array];
  for (FUIFakeSnapshot *snapshot in items) {
    [result addObject:snapshot.key];
  }
  
  XCTAssert([result isEqual:expected], @"expected firebaseArray contents to equal %@, got %@", expected, [result copy]);
}

- (void)testFirebaseArrayCanInsertAtBeginning {
  // Setup boilerplate
  [self.observable populateWithCount:10];
  self.snap.key = @"0";
  
  // Insert at beginning
  [self.observable sendEvent:FIRDataEventTypeChildAdded withObject:self.snap previousKey:nil error:nil];
  
  // Expectation boilerplate
  NSArray *items = self.firebaseArray.items;
  NSArray *expected = @[@"0", @"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9"];
  NSMutableArray *result = [NSMutableArray array];
  for (FUIFakeSnapshot *snapshot in items) {
    [result addObject:snapshot.key];
  }
  
  XCTAssert([result isEqual:expected], @"expected firebaseArray contents to equal %@, got %@", expected, [result copy]);
}

- (void)testFirebaseArrayCanInsertAtEnd {
  // Setup boilerplate
  [self.observable populateWithCount:10];
  self.snap.key = @"10";
  
  // Insert at end
  [self.observable sendEvent:FIRDataEventTypeChildAdded withObject:self.snap previousKey:@"9" error:nil];
  
  // Expectation boilerplate
  NSArray *items = self.firebaseArray.items;
  NSArray *expected = @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10"];
  NSMutableArray *result = [NSMutableArray array];
  for (FUIFakeSnapshot *snapshot in items) {
    [result addObject:snapshot.key];
  }
  
  XCTAssert([result isEqual:expected], @"expected firebaseArray contents to equal %@, got %@", expected, [result copy]);
}

- (void)testFirebaseArrayCanInsertIntoUniformArray {
  // Setup boilerplate
  [self.observable populateWithCount:10 generator:^FUIFakeSnapshot *(NSUInteger i) {
    FUIFakeSnapshot *snap = [[FUIFakeSnapshot alloc] init];
    snap.key = @"1";
    return snap;
  }];
  self.snap.key = @"1";
  
  // Insert after @"1", which is ambiguous
  [self.observable sendEvent:FIRDataEventTypeChildAdded withObject:self.snap previousKey:@"1" error:nil];
  
  // Expectation boilerplate
  NSArray *items = self.firebaseArray.items;
  NSArray *expected = @[@"1", @"1", @"1", @"1", @"1", @"1", @"1", @"1", @"1", @"1", @"1"];
  NSMutableArray *result = [NSMutableArray array];
  for (FUIFakeSnapshot *snapshot in items) {
    [result addObject:snapshot.key];
  }
  
  XCTAssert([result isEqual:expected], @"expected firebaseArray contents to equal %@, got %@", expected, [result copy]);
}

- (void)testFirebaseCanInsertIntoArrayWithDuplicates {
  // Setup boilerplate
  [self.observable populateWithCount:10 generator:^FUIFakeSnapshot *(NSUInteger i) {
    FUIFakeSnapshot *snap = [[FUIFakeSnapshot alloc] init];
    // Since insertion with duplicates is ambiguous and is resolved by
    // always inserting at the first element identical to the
    // previous sibling, this series of insertions will produce
    // unexpected results.
    snap.key = ((i % 3 == 0) ? @"1" : @"0");
    NSLog(@"index: %lu, key: %@", i, snap.key);
    return snap;
  }];
  self.snap.key = @"1";
  
  // Insert after @"1", which is ambiguous again
  [self.observable sendEvent:FIRDataEventTypeChildAdded withObject:self.snap previousKey:@"1" error:nil];
  
  // Expectation boilerplate
  NSArray *items = self.firebaseArray.items;
  // The insertion point (after the first 1) of this ambiguous insert
  // is a leaky implementation detail and could be considered a bug.
  NSArray *expected = @[@"1", @"1", @"0", @"1", @"0", @"0", @"1", @"0", @"0", @"1", @"0"];
  NSMutableArray *result = [NSMutableArray array];
  for (FUIFakeSnapshot *snapshot in items) {
    [result addObject:snapshot.key];
  }
  
  XCTAssert([result isEqual:expected], @"expected firebaseArray contents to equal %@, got %@", expected, [result copy]);
}

#pragma mark - Deletion

- (void)testFirebaseArrayCanDeleteOneElementArray {
  // Insert a key
  self.snap.key = @"snapshot";
  [self.observable sendEvent:FIRDataEventTypeChildAdded
                  withObject:self.snap
                 previousKey:nil
                       error:nil];
  
  // Delete
  [self.observable sendEvent:FIRDataEventTypeChildRemoved
                  withObject:self.snap
                 previousKey:nil
                       error:nil];
  
  XCTAssert(self.firebaseArray.count == 0,
            @"expected empty array to still be empty after one insertion and one deletion");
}

- (void)testFirebaseArrayCanDeleteFirstElement {
  [self.observable populateWithCount:10];
  self.snap.key = @"0";
  
  [self.observable sendEvent:FIRDataEventTypeChildRemoved withObject:self.snap previousKey:nil error:nil];
  
  // Expectation boilerplate
  NSArray *items = self.firebaseArray.items;
  NSArray *expected = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9"];
  NSMutableArray *result = [NSMutableArray array];
  for (FUIFakeSnapshot *snapshot in items) {
    [result addObject:snapshot.key];
  }
  
  XCTAssert([result isEqual:expected], @"expected firebaseArray contents to equal %@, got %@", expected, [result copy]);
}

- (void)testFirebaseArrayCanDeleteLastElement {
  [self.observable populateWithCount:10];
  self.snap.key = @"9";
  
  [self.observable sendEvent:FIRDataEventTypeChildRemoved withObject:self.snap previousKey:@"8" error:nil];
  
  // Expectation boilerplate
  NSArray *items = self.firebaseArray.items;
  NSArray *expected = @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8"];
  NSMutableArray *result = [NSMutableArray array];
  for (FUIFakeSnapshot *snapshot in items) {
    [result addObject:snapshot.key];
  }
  
  XCTAssert([result isEqual:expected], @"expected firebaseArray contents to equal %@, got %@", expected, [result copy]);
}

- (void)testFirebaseArrayCanDeleteMiddleElement {
  [self.observable populateWithCount:10];
  self.snap.key = @"5";
  
  [self.observable sendEvent:FIRDataEventTypeChildRemoved withObject:self.snap previousKey:@"4" error:nil];
  
  // Expectation boilerplate
  NSArray *items = self.firebaseArray.items;
  NSArray *expected = @[@"0", @"1", @"2", @"3", @"4", @"6", @"7", @"8", @"9"];
  NSMutableArray *result = [NSMutableArray array];
  for (FUIFakeSnapshot *snapshot in items) {
    [result addObject:snapshot.key];
  }
  
  XCTAssert([result isEqual:expected], @"expected firebaseArray contents to equal %@, got %@", expected, [result copy]);
}

- (void)testFirebaseArrayCanModifyElement {
  // TODO: Make this test less bad
  [self.observable populateWithCount:10];
  self.snap.key = @"5";
  
  [self.observable sendEvent:FIRDataEventTypeChildChanged withObject:self.snap previousKey:@"4" error:nil];
  
  // Expectation boilerplate
  NSArray *items = self.firebaseArray.items;
  // Current implementation doesn't change the key of the snap on child change.
  NSArray *expected = @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9"];
  NSMutableArray *result = [NSMutableArray array];
  for (FUIFakeSnapshot *snapshot in items) {
    [result addObject:snapshot.key];
  }
  
  XCTAssert([result isEqual:expected], @"expected firebaseArray contents to equal %@, got %@", expected, [result copy]);
}

- (void)testirebaseArrayCanMoveElement {
  [self.observable populateWithCount:10];
  self.snap.key = @"8";
  
  // Move 8 to after 2
  [self.observable sendEvent:FIRDataEventTypeChildMoved withObject:self.snap previousKey:@"2" error:nil];
  
  // Expectation boilerplate
  NSArray *items = self.firebaseArray.items;
  NSArray *expected = @[@"0", @"1", @"2", @"8", @"3", @"4", @"5", @"6", @"7", @"9"];
  NSMutableArray *result = [NSMutableArray array];
  for (FUIFakeSnapshot *snapshot in items) {
    [result addObject:snapshot.key];
  }
  
  XCTAssert([result isEqual:expected], @"expected firebaseArray contents to equal %@, got %@", expected, [result copy]);
}

// TODO: add tests for arrays with uniques after we figure out what we want the desired behavior to be

@end
