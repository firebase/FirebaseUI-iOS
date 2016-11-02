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

@import XCTest;
@import FirebaseDatabaseUI;

#import "FUISortedArray.h"

#import "FUIDatabaseTestUtils.h"

@interface FUISortedArrayTest : XCTestCase

@property (nonatomic, nullable) FUIArrayTestDelegate *arrayDelegate;
@property (nonatomic, nullable) FUITestObservable *observable;
@property (nonatomic, nullable) FUISortedArray *array;
@property (nonatomic, nullable) FUIFakeSnapshot *snap;

@end

@implementation FUISortedArrayTest

- (void)setUp {
  [super setUp];
  self.arrayDelegate = [[FUIArrayTestDelegate alloc] init];
  self.snap = [[FUIFakeSnapshot alloc] init];
  self.observable = [[FUITestObservable alloc] init];
  self.array = [[FUISortedArray alloc] initWithQuery:self.observable
                                            delegate:self.arrayDelegate
                                      sortDescriptor:^NSComparisonResult(FIRDataSnapshot *left,
                                                                         FIRDataSnapshot *right) {
    return [left.key compare:right.key];
  }];
  [self.array observeQuery];
}

- (void)tearDown {
  [super tearDown];
}

- (void)testArrayCanBeInitialized {
  XCTAssertNotNil(self.array, @"expected array to not be nil when initialized");
}

- (void)testItSortsItselfOnMiddleInsert {
  [self.observable populateWithCount:10];

  // Test delegate
  __block BOOL delegateWasCalled = NO;
  __block BOOL expectedParametersWereCorrect = NO;
  self.arrayDelegate.didAddObject = ^(FUISortedArray *array, id object, NSUInteger index) {
    // Xcode complains about retain cycles if an XCTAssert is placed in here.
    delegateWasCalled = YES;
    expectedParametersWereCorrect = (array == self.array &&
                                     object == self.snap &&
                                     // index should be 2 since "11" comes before "2" alphabetically.
                                     index == 2);
  };

  // Test insert
  self.snap.key = @"11";
  [self.observable sendEvent:FIRDataEventTypeChildAdded
                  withObject:self.snap
                 previousKey:@"0" // insert after "0" should be ignored to maintain sort
                       error:nil];
  // Array expectations
  XCTAssert(self.array.count == 11, @"expected empty array to contain one item after insert");

  // Delegate expectations
  XCTAssert(delegateWasCalled, @"expected delegate to receive callback for insertion");
  XCTAssert(expectedParametersWereCorrect, @"unexpected parameter in delegate callback");
}

- (void)testItSortsItselfOnBeginningInsert {
  [self.observable populateWithCount:10];

  // Test delegate
  __block BOOL delegateWasCalled = NO;
  __block BOOL expectedParametersWereCorrect = NO;
  self.arrayDelegate.didAddObject = ^(FUISortedArray *array, id object, NSUInteger index) {
    // Xcode complains about retain cycles if an XCTAssert is placed in here.
    delegateWasCalled = YES;
    expectedParametersWereCorrect = (array == self.array &&
                                     object == self.snap &&
                                     // index should be 0 since "+" comes before "0" alphabetically.
                                     index == 0);
  };

  // Test insert
  self.snap.key = @"+";
  [self.observable sendEvent:FIRDataEventTypeChildAdded
                  withObject:self.snap
                 previousKey:@"0" // insert after "0" should be ignored to maintain sort
                       error:nil];
  // Array expectations
  XCTAssert(self.array.count == 11, @"expected empty array to contain one item after insert");

  // Delegate expectations
  XCTAssert(delegateWasCalled, @"expected delegate to receive callback for insertion");
  XCTAssert(expectedParametersWereCorrect, @"unexpected parameter in delegate callback");
}

- (void)testItSortsItselfOnEndInsert {
  [self.observable populateWithCount:10];

  // Test delegate
  __block BOOL delegateWasCalled = NO;
  __block BOOL expectedParametersWereCorrect = NO;
  self.arrayDelegate.didAddObject = ^(FUISortedArray *array, id object, NSUInteger index) {
    // Xcode complains about retain cycles if an XCTAssert is placed in here.
    delegateWasCalled = YES;
    expectedParametersWereCorrect = (array == self.array &&
                                     object == self.snap &&
                                     // index should be 10 since "a" comes after "9" alphabetically.
                                     index == 10);
  };

  // Test insert
  self.snap.key = @"a";
  [self.observable sendEvent:FIRDataEventTypeChildAdded
                  withObject:self.snap
                 previousKey:@"0" // insert after "0" should be ignored to maintain sort
                       error:nil];
  // Array expectations
  XCTAssert(self.array.count == 11, @"expected empty array to contain one item after insert");

  // Delegate expectations
  XCTAssert(delegateWasCalled, @"expected delegate to receive callback for insertion");
  XCTAssert(expectedParametersWereCorrect, @"unexpected parameter in delegate callback");
}

- (void)testEmptyArrayUpdatesCountOnInsert {
  // Test delegate
  __block BOOL delegateWasCalled = NO;
  __block BOOL expectedParametersWereCorrect = NO;
  self.arrayDelegate.didAddObject = ^(FUISortedArray *array, id object, NSUInteger index) {
    // Xcode complains about retain cycles if an XCTAssert is placed in here.
    delegateWasCalled = YES;
    expectedParametersWereCorrect = (array == self.array &&
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
  XCTAssert(self.array.count == 1, @"expected empty array to contain one item after insert");

  // Delegate expectations
  XCTAssert(delegateWasCalled, @"expected delegate to receive callback for insertion");
  XCTAssert(expectedParametersWereCorrect, @"unexpected parameter in delegate callback");
}

@end
