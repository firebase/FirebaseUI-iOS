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
@import FirebaseDatabaseUI;

#import "FUIDatabaseTestUtils.h"
#import "FUIIndexArray.h"

@interface FUIIndexArrayTest : XCTestCase
@property (nonatomic) FUITestObservable *index;
@property (nonatomic) FUITestObservable *data;
@property (nonatomic) FUIIndexArray *array;
@property (nonatomic) FUIIndexArrayTestDelegate *arrayDelegate;

@property (nonatomic) NSMutableDictionary *dict;
@end

@implementation FUIIndexArrayTest

static inline NSDictionary *database() {
  static NSDictionary *dict;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    dict = @{
      @"index": @{
        @"1": @(YES),
        @"2": @(YES),
        @"3": @(YES),
      },
      @"data": @{
        @"1": @{ @"data": @"1" },
        @"2": @{ @"data": @"2" },
        @"3": @{ @"data": @"3" },
      },
    };
  });
  return dict;
}

- (void)setUp {
  [super setUp];
  self.index = [[FUITestObservable alloc] initWithDictionary:database()[@"index"]];
  self.data = [[FUITestObservable alloc] initWithDictionary:database()[@"data"]];
  self.array = [[FUIIndexArray alloc] initWithIndex:self.index
                                               data:self.data];
  self.arrayDelegate = [[FUIIndexArrayTestDelegate alloc] init];
  self.array.delegate = self.arrayDelegate;
  self.dict = [database() mutableCopy];
}

- (void)tearDown {
  [super tearDown];
  [self.array invalidate];
  self.array = nil;
  self.arrayDelegate = nil;
}

- (void)testItHasContents {
  NSArray *indexes = self.array.indexes;
  NSArray *items = self.array.items;

  NSArray *expectedIndexes = @[
    [FUIFakeSnapshot snapWithKey:@"1" value:@(YES)],
    [FUIFakeSnapshot snapWithKey:@"2" value:@(YES)],
    [FUIFakeSnapshot snapWithKey:@"3" value:@(YES)],
  ];

  NSArray *expectedContents = @[
    [FUIFakeSnapshot snapWithKey:@"data" value:@"1"],
    [FUIFakeSnapshot snapWithKey:@"data" value:@"2"],
    [FUIFakeSnapshot snapWithKey:@"data" value:@"3"],
  ];

  XCTAssertEqualObjects(indexes, expectedIndexes, @"expected indexes to equal %@", expectedIndexes);
  XCTAssertEqualObjects(items, expectedContents, @"expected contents to equal %@", expectedContents);
}

- (void)testItUpdatesOnInsertion {
  // check expected number of items
  NSArray *items = self.array.items;
  XCTAssert(items.count == 3, @"expected %i keys, got %li", 3, items.count);

  // test delegate
  __block BOOL delegateWasCalled = NO;
  __block BOOL expectedParametersWereCorrect = NO;

  self.arrayDelegate.didAddQuery = ^(FUIIndexArray *array, FIRDatabaseReference *query, NSUInteger index) {
    delegateWasCalled = YES;
    expectedParametersWereCorrect = (
      array == self.array &&
      index == 3
    );
  };

  // insert item
  [self.data addObject:@{ @"data": @"4" } forKey:@"4"];
  [self.index addObject:@(YES) forKey:@"4"];

  XCTAssert(delegateWasCalled, @"expected insertion to call method on delegate");
  XCTAssert(expectedParametersWereCorrect, @"expected insertion to call delegate method with correct params");

  items = self.array.items;

  NSArray *expected = @[
    [FUIFakeSnapshot snapWithKey:@"data" value:@"1"],
    [FUIFakeSnapshot snapWithKey:@"data" value:@"2"],
    [FUIFakeSnapshot snapWithKey:@"data" value:@"3"],
    [FUIFakeSnapshot snapWithKey:@"data" value:@"4"],
  ];

  XCTAssertEqualObjects(items, expected, @"expected contents to equal %@", expected);
}

- (void)testItUpdatesOnDeletion {
  // check expected number of items
  NSArray *items = self.array.items;
  XCTAssert(items.count == 3, @"expected %i keys, got %li", 3, items.count);

  // test delegate
  __block BOOL delegateWasCalled = NO;
  __block BOOL expectedParametersWereCorrect = NO;

  self.arrayDelegate.didRemoveQuery = ^(FUIIndexArray *array, FIRDatabaseReference *query, NSUInteger index) {
    delegateWasCalled = YES;
    expectedParametersWereCorrect = (
      array == self.array &&
      index == 1
    );
  };

  // delete item
  [self.data removeObjectForKey:@"2"];
  [self.index removeObjectForKey:@"2"];

  XCTAssert(delegateWasCalled, @"expected deletion to call method on delegate");
  XCTAssert(expectedParametersWereCorrect, @"expected deletion to call delegate method with correct params");

  items = self.array.items;

  NSArray *expected = @[
    [FUIFakeSnapshot snapWithKey:@"data" value:@"1"],
    [FUIFakeSnapshot snapWithKey:@"data" value:@"3"],
  ];

  XCTAssertEqualObjects(items, expected, @"expected contents to equal %@", expected);
}

- (void)testItCanDeleteEdgeCases {
  // check expected number of items
  NSArray *items = self.array.items;
  XCTAssert(items.count == 3, @"expected %i keys, got %li", 3, items.count);

  // delete first item
  [self.data removeObjectForKey:@"1"];
  [self.index removeObjectForKey:@"1"];

  items = self.array.items;

  NSArray *expected = @[
    [FUIFakeSnapshot snapWithKey:@"data" value:@"2"],
    [FUIFakeSnapshot snapWithKey:@"data" value:@"3"],
  ];

  XCTAssertEqualObjects(items, expected, @"expected contents to equal %@", expected);

  // delete last item
  [self.data removeObjectForKey:@"3"];
  [self.index removeObjectForKey:@"3"];

  items = self.array.items;

  expected = @[
    [FUIFakeSnapshot snapWithKey:@"data" value:@"2"],
  ];

  XCTAssertEqualObjects(items, expected, @"expected contents to equal %@", expected);

  // delete single item
  [self.index removeObjectForKey:@"2"];

  items = self.array.items;

  expected = @[];

  XCTAssertEqualObjects(items, expected, @"expected contents to equal %@", expected);
}

- (void)testItUpdatesOnChange {
  // check expected number of items
  NSArray *items = self.array.items;
  XCTAssert(items.count == 3, @"expected %i keys, got %li", 3, items.count);

  // test delegate
  __block BOOL delegateWasCalled = NO;
  __block BOOL expectedParametersWereCorrect = NO;

  self.arrayDelegate.didChangeQuery = ^(FUIIndexArray *array, FIRDatabaseReference *query, NSUInteger index) {
    delegateWasCalled = YES;
    expectedParametersWereCorrect = (
      array == self.array &&
      index == 1
    );
  };

  // change item
  [self.data changeObject:@{ @"data": @"changed" } forKey:@"2"];
  [self.index changeObject:@(YES) forKey:@"2"];

  XCTAssert(delegateWasCalled, @"expected change to call method on delegate");
  XCTAssert(expectedParametersWereCorrect, @"expected change to call delegate method with correct params");

  items = self.array.items;

  NSArray *expected = @[
    [FUIFakeSnapshot snapWithKey:@"data" value:@"1"],
    [FUIFakeSnapshot snapWithKey:@"data" value:@"changed"],
    [FUIFakeSnapshot snapWithKey:@"data" value:@"3"],
  ];

  XCTAssertEqualObjects(items, expected, @"expected contents to equal %@", expected);
}

- (void)testItUpdatesOnMove {
  // check expected number of items
  NSArray *items = self.array.items;
  XCTAssert(items.count == 3, @"expected %i keys, got %li", 3, items.count);

  // test delegate
  __block BOOL delegateWasCalled = NO;
  __block BOOL expectedParametersWereCorrect = NO;

  self.arrayDelegate.didMoveQuery = ^(FUIIndexArray *array,
                                      FIRDatabaseReference *query,
                                      NSUInteger from,
                                      NSUInteger to) {
    delegateWasCalled = YES;
    expectedParametersWereCorrect = (
      array == self.array &&
      from == 0 &&
      to == 2
    );
  };

  // move item to back
  [self.data moveObjectFromIndex:0 toIndex:2];
  [self.index moveObjectFromIndex:0 toIndex:2];

  XCTAssert(delegateWasCalled, @"expected move to call method on delegate");
  XCTAssert(expectedParametersWereCorrect, @"expected move to call delegate method with correct params");

  items = self.array.items;

  NSArray *expected = @[
    [FUIFakeSnapshot snapWithKey:@"data" value:@"2"],
    [FUIFakeSnapshot snapWithKey:@"data" value:@"3"],
    [FUIFakeSnapshot snapWithKey:@"data" value:@"1"],
  ];

  XCTAssertEqualObjects(items, expected, @"expected contents to equal %@", expected);

  // move item to front
  [self.data moveObjectFromIndex:2 toIndex:0];
  [self.index moveObjectFromIndex:2 toIndex:0];

  items = self.array.items;

  expected = @[
    [FUIFakeSnapshot snapWithKey:@"data" value:@"1"],
    [FUIFakeSnapshot snapWithKey:@"data" value:@"2"],
    [FUIFakeSnapshot snapWithKey:@"data" value:@"3"],
  ];

  XCTAssertEqualObjects(items, expected, @"expected contents to equal %@", expected);
}

@end
