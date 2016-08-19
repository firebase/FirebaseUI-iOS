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
#import "FirebaseArrayTestUtils.h"

@interface FirebaseArrayTest : XCTestCase

@property (nonatomic, nullable) FUIFirebaseArrayTestDelegate *arrayDelegate;
@property (nonatomic, nullable) FUITestObservable *observable;
@property (nonatomic, nullable) FirebaseArray *firebaseArray;
@property (nonatomic, nullable) FUIFakeSnapshot *snap;

@end

@implementation FirebaseArrayTest

- (void)setUp {
  [super setUp];
  self.arrayDelegate = [[FUIFirebaseArrayTestDelegate alloc] init];
  self.snap = [[FUIFakeSnapshot alloc] init];
  self.observable = [[FUITestObservable alloc] init];
  self.firebaseArray = [[FirebaseArray alloc] initWithQuery:self.observable];
  self.firebaseArray.delegate = self.arrayDelegate;
}

- (void)tearDown {
  [super tearDown];
  [self.observable removeAllObservers];
  self.arrayDelegate = nil;
}

#pragma mark - Insertion

- (void)testFirebaseArrayCanBeInitialized {
  XCTAssertNotNil(self.firebaseArray, @"expected FirebaseArray to not be nil when initialized");
}

- (void)testEmptyFirebaseArrayUpdatesCountOnInsert {
  // Test delegate
  __block BOOL delegateWasCalled = NO;
  __block BOOL expectedParametersWereCorrect = NO;
  self.arrayDelegate.didAddObject = ^(FirebaseArray *array, id object, NSUInteger index) {
    // Xcode complains about retain cycles if an XCTAssert is placed in here.
    delegateWasCalled = YES;
    expectedParametersWereCorrect = (array == self.firebaseArray &&
                                     object == self.snap &&
                                     index == 0);
  };
  
  // Test insert
  self.snap.key = @"snapshot";
  [self.observable sendEvent:FIRDataEventTypeChildAdded
                  withObject:self.snap
                 previousKey:nil
                       error:nil];
  // Array expectations
  XCTAssert(self.firebaseArray.count == 1, @"expected empty array to contain one item after insert");
  
  // Delegate expectations
  XCTAssert(delegateWasCalled, @"expected delegate to receive callback for insertion");
  XCTAssert(expectedParametersWereCorrect, @"unexpected parameter in delegate callback");
}

- (void)testFirebaseArrayCanInsertInMiddle {
  // Setup boilerplate
  [self.observable populateWithCount:10];
  self.snap.key = @"5";
  
  // Test delegate
  __block BOOL delegateWasCalled = NO;
  __block BOOL expectedParametersWereCorrect = NO;
  self.arrayDelegate.didAddObject = ^(FirebaseArray *array, id object, NSUInteger index) {
    // Xcode complains about retain cycles if an XCTAssert is placed in here.
    delegateWasCalled = YES;
    expectedParametersWereCorrect = (array == self.firebaseArray &&
                                     object == self.snap &&
                                     index == 5);
  };
  
  // Insert in middle
  [self.observable sendEvent:FIRDataEventTypeChildAdded withObject:self.snap previousKey:@"4" error:nil];
  
  // Array expectations
  NSArray *items = self.firebaseArray.items;
  NSArray *expected = @[@"0", @"1", @"2", @"3", @"4", @"5", @"5", @"6", @"7", @"8", @"9"];
  NSMutableArray *result = [NSMutableArray array];
  for (FUIFakeSnapshot *snapshot in items) {
    [result addObject:snapshot.key];
  }
  XCTAssert([result isEqual:expected], @"expected firebaseArray contents to equal %@, got %@", expected, [result copy]);
  
  // Delegate expectations
  XCTAssert(delegateWasCalled, @"expected delegate to receive callback for insertion");
  XCTAssert(expectedParametersWereCorrect, @"unexpected parameter in delegate callback");
}

- (void)testFirebaseArrayCanInsertAtBeginning {
  // Setup boilerplate
  [self.observable populateWithCount:10];
  self.snap.key = @"0";
  
  // Test delegate
  __block BOOL delegateWasCalled = NO;
  __block BOOL expectedParametersWereCorrect = NO;
  self.arrayDelegate.didAddObject = ^(FirebaseArray *array, id object, NSUInteger index) {
    // Xcode complains about retain cycles if an XCTAssert is placed in here.
    delegateWasCalled = YES;
    expectedParametersWereCorrect = (array == self.firebaseArray &&
                                     object == self.snap &&
                                     index == 0);
  };
  
  // Insert at beginning
  [self.observable sendEvent:FIRDataEventTypeChildAdded withObject:self.snap previousKey:nil error:nil];
  
  // Array expectations
  NSArray *items = self.firebaseArray.items;
  NSArray *expected = @[@"0", @"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9"];
  NSMutableArray *result = [NSMutableArray array];
  for (FUIFakeSnapshot *snapshot in items) {
    [result addObject:snapshot.key];
  }
  XCTAssert([result isEqual:expected], @"expected firebaseArray contents to equal %@, got %@", expected, [result copy]);
  
  // Delegate expectations
  XCTAssert(delegateWasCalled, @"expected delegate to receive callback for insertion");
  XCTAssert(expectedParametersWereCorrect, @"unexpected parameter in delegate callback");
}

- (void)testFirebaseArrayCanInsertAtEnd {
  // Setup boilerplate
  [self.observable populateWithCount:10];
  self.snap.key = @"10";
  
  // Test delegate
  __block BOOL delegateWasCalled = NO;
  __block BOOL expectedParametersWereCorrect = NO;
  self.arrayDelegate.didAddObject = ^(FirebaseArray *array, id object, NSUInteger index) {
    // Xcode complains about retain cycles if an XCTAssert is placed in here.
    delegateWasCalled = YES;
    expectedParametersWereCorrect = (array == self.firebaseArray &&
                                     object == self.snap &&
                                     index == 10);
  };
  
  // Insert at end
  [self.observable sendEvent:FIRDataEventTypeChildAdded withObject:self.snap previousKey:@"9" error:nil];
  
  // Array expectations
  NSArray *items = self.firebaseArray.items;
  NSArray *expected = @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10"];
  NSMutableArray *result = [NSMutableArray array];
  for (FUIFakeSnapshot *snapshot in items) {
    [result addObject:snapshot.key];
  }
  XCTAssert([result isEqual:expected], @"expected firebaseArray contents to equal %@, got %@", expected, [result copy]);
  
  // Delegate expectations
  XCTAssert(delegateWasCalled, @"expected delegate to receive callback for insertion");
  XCTAssert(expectedParametersWereCorrect, @"unexpected parameter in delegate callback");
}

#pragma mark - Deletion

- (void)testFirebaseArrayCanDeleteOneElementArray {
  // Insert a key
  self.snap.key = @"snapshot";
  [self.observable sendEvent:FIRDataEventTypeChildAdded
                  withObject:self.snap
                 previousKey:nil
                       error:nil];
  
  // Test delegate
  __block BOOL delegateWasCalled = NO;
  __block BOOL expectedParametersWereCorrect = NO;
  self.arrayDelegate.didRemoveObject = ^(FirebaseArray *array, id object, NSUInteger index) {
    // Xcode complains about retain cycles if an XCTAssert is placed in here.
    delegateWasCalled = YES;
    expectedParametersWereCorrect = (array == self.firebaseArray &&
                                     object == self.snap &&
                                     index == 0);
  };
  
  // Delete
  [self.observable sendEvent:FIRDataEventTypeChildRemoved
                  withObject:self.snap
                 previousKey:nil
                       error:nil];
  // Array expectation
  XCTAssert(self.firebaseArray.count == 0,
            @"expected empty array to still be empty after one insertion and one deletion");
  
  // Delegate expectations
  XCTAssert(delegateWasCalled, @"expected delegate to receive callback for deletion");
  XCTAssert(expectedParametersWereCorrect, @"unexpected parameter in delegate callback");
}

- (void)testFirebaseArrayCanDeleteFirstElement {
  [self.observable populateWithCount:10];
  self.snap.key = @"0";
  
  // Test delegate
  __block BOOL delegateWasCalled = NO;
  __block BOOL expectedParametersWereCorrect = NO;
  self.arrayDelegate.didRemoveObject = ^(FirebaseArray *array, id object, NSUInteger index) {
    // Xcode complains about retain cycles if an XCTAssert is placed in here.
    delegateWasCalled = YES;
    expectedParametersWereCorrect = (array == self.firebaseArray &&
                                     object == self.snap &&
                                     index == 0);
  };
  
  [self.observable sendEvent:FIRDataEventTypeChildRemoved withObject:self.snap previousKey:nil error:nil];
  
  // Array expectations
  NSArray *items = self.firebaseArray.items;
  NSArray *expected = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9"];
  NSMutableArray *result = [NSMutableArray array];
  for (FUIFakeSnapshot *snapshot in items) {
    [result addObject:snapshot.key];
  }
  XCTAssert([result isEqual:expected], @"expected firebaseArray contents to equal %@, got %@", expected, [result copy]);
  
  // Delegate expectations
  XCTAssert(delegateWasCalled, @"expected delegate to receive callback for deletion");
  XCTAssert(expectedParametersWereCorrect, @"unexpected parameter in delegate callback");
}

- (void)testFirebaseArrayCanDeleteLastElement {
  [self.observable populateWithCount:10];
  self.snap.key = @"9";
  
  // Test delegate
  __block BOOL delegateWasCalled = NO;
  __block BOOL expectedParametersWereCorrect = NO;
  self.arrayDelegate.didRemoveObject = ^(FirebaseArray *array, id object, NSUInteger index) {
    // Xcode complains about retain cycles if an XCTAssert is placed in here.
    delegateWasCalled = YES;
    expectedParametersWereCorrect = (array == self.firebaseArray &&
                                     object == self.snap &&
                                     index == 9);
  };
  
  // Delete last element
  [self.observable sendEvent:FIRDataEventTypeChildRemoved withObject:self.snap previousKey:@"8" error:nil];
  
  // Array expectations
  NSArray *items = self.firebaseArray.items;
  NSArray *expected = @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8"];
  NSMutableArray *result = [NSMutableArray array];
  for (FUIFakeSnapshot *snapshot in items) {
    [result addObject:snapshot.key];
  }
  XCTAssert([result isEqual:expected], @"expected firebaseArray contents to equal %@, got %@", expected, [result copy]);
  
  // Delegate expectations
  XCTAssert(delegateWasCalled, @"expected delegate to receive callback for deletion");
  XCTAssert(expectedParametersWereCorrect, @"unexpected parameter in delegate callback");
}

- (void)testFirebaseArrayCanDeleteMiddleElement {
  [self.observable populateWithCount:10];
  self.snap.key = @"5";
  
  // Test delegate
  __block BOOL delegateWasCalled = NO;
  __block BOOL expectedParametersWereCorrect = NO;
  self.arrayDelegate.didRemoveObject = ^(FirebaseArray *array, id object, NSUInteger index) {
    // Xcode complains about retain cycles if an XCTAssert is placed in here.
    delegateWasCalled = YES;
    expectedParametersWereCorrect = (array == self.firebaseArray &&
                                     object == self.snap &&
                                     index == 5);
  };
  
  // Delete element
  [self.observable sendEvent:FIRDataEventTypeChildRemoved withObject:self.snap previousKey:@"4" error:nil];
  
  // Array expectation
  NSArray *items = self.firebaseArray.items;
  NSArray *expected = @[@"0", @"1", @"2", @"3", @"4", @"6", @"7", @"8", @"9"];
  NSMutableArray *result = [NSMutableArray array];
  for (FUIFakeSnapshot *snapshot in items) {
    [result addObject:snapshot.key];
  }
  XCTAssert([result isEqual:expected], @"expected firebaseArray contents to equal %@, got %@", expected, [result copy]);
  
  // Delegate expectations
  XCTAssert(delegateWasCalled, @"expected delegate to receive callback for deletion");
  XCTAssert(expectedParametersWereCorrect, @"unexpected parameter in delegate callback");
}

#pragma mark - Modifying elements

- (void)testFirebaseArrayCanModifyElement {
  [self.observable populateWithCount:10];
  self.snap.key = @"5";
  self.snap.value = @"a value";
  
  // Test delegate
  __block BOOL delegateWasCalled = NO;
  __block BOOL expectedParametersWereCorrect = NO;
  self.arrayDelegate.didChangeObject = ^(FirebaseArray *array, id object, NSUInteger index) {
    // Xcode complains about retain cycles if an XCTAssert is placed in here.
    delegateWasCalled = YES;
    expectedParametersWereCorrect = (array == self.firebaseArray &&
                                     object == self.snap &&
                                     index == 5);
  };
  
  [self.observable sendEvent:FIRDataEventTypeChildChanged withObject:self.snap previousKey:@"4" error:nil];
  
  // Array expectation
  NSArray *items = self.firebaseArray.items;
  NSArray *expected = @[@"0", @"1", @"2", @"3", @"4", @"a value", @"6", @"7", @"8", @"9"];
  NSMutableArray *result = [NSMutableArray array];
  for (FUIFakeSnapshot *snapshot in items) {
    [result addObject:snapshot.value];
  }
  XCTAssert([result isEqual:expected], @"expected firebaseArray contents to equal %@, got %@", expected, [result copy]);
  
  // Delegate expectations
  XCTAssert(delegateWasCalled, @"expected delegate to receive callback for deletion");
  XCTAssert(expectedParametersWereCorrect, @"unexpected parameter in delegate callback");
}

#pragma mark - Moving elements

- (void)testFirebaseArrayCanMoveElement {
  [self.observable populateWithCount:10];
  self.snap.key = @"8";
  
  // Test delegate
  __block BOOL delegateWasCalled = NO;
  __block BOOL expectedParametersWereCorrect = NO;
  self.arrayDelegate.didMoveObject = ^(FirebaseArray *array, id object, NSUInteger from, NSUInteger to) {
    // Xcode complains about retain cycles if an XCTAssert is placed in here.
    delegateWasCalled = YES;
    expectedParametersWereCorrect = (array == self.firebaseArray &&
                                     object == self.snap &&
                                     from == 8 && to == 3);
  };
  
  // Move 8 to after 2
  [self.observable sendEvent:FIRDataEventTypeChildMoved withObject:self.snap previousKey:@"2" error:nil];
  
  // Array expectation
  NSArray *items = self.firebaseArray.items;
  NSArray *expected = @[@"0", @"1", @"2", @"8", @"3", @"4", @"5", @"6", @"7", @"9"];
  NSMutableArray *result = [NSMutableArray array];
  for (FUIFakeSnapshot *snapshot in items) {
    [result addObject:snapshot.key];
  }
  XCTAssert([result isEqual:expected], @"expected firebaseArray contents to equal %@, got %@", expected, [result copy]);
  
  // Delegate expectations
  XCTAssert(delegateWasCalled, @"expected delegate to receive callback for deletion");
  XCTAssert(expectedParametersWereCorrect, @"unexpected parameter in delegate callback");
}

@end
