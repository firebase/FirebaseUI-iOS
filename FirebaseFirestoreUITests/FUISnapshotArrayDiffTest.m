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

#import "FUISnapshotArrayDiff.h"
#import "FUIDocumentChange.h"

@interface FUISnapshotArrayDiffTest : XCTestCase

@end

@implementation FUISnapshotArrayDiffTest

- (void)setUp {
  [super setUp];
}

- (void)tearDown {
  [super tearDown];
}

// TODO(morganchen): Add indexes to these tests too
#pragma mark - General diff (without Firestore documentChanges)

- (void)testDiffEdgeCases {
  NSArray *initial = @[];
  NSArray *result = @[];

  FUISnapshotArrayDiff *diff = [[FUISnapshotArrayDiff alloc] initWithInitialArray:initial
                                                                      resultArray:result];

  XCTAssert(diff.deletedObjects.count == 0, @"expected diff between empty arrays to be empty");
  XCTAssert(diff.insertedObjects.count == 0, @"expected diff between empty arrays to be empty");
  XCTAssert(diff.changedObjects.count == 0, @"expected diff between empty arrays to be empty");
  XCTAssert(diff.movedObjects.count == 0, @"expected diff between empty arrays to be empty");

  initial = @[[FUIDocumentSnapshot documentWithID:@"a"], [FUIDocumentSnapshot documentWithID:@"b"]];
  result = @[];
  diff = [[FUISnapshotArrayDiff alloc] initWithInitialArray:initial
                                                resultArray:result];

  NSArray *expectedDeletions, *expectedInsertions, *expectedChanges, *expectedMoves;
  expectedDeletions = @[
    [FUIDocumentSnapshot documentWithID:@"a"],
    [FUIDocumentSnapshot documentWithID:@"b"]
  ];
  XCTAssertEqualObjects(diff.deletedObjects, expectedDeletions,
                        @"expected deletions to equal %@, got %@",
                        expectedDeletions, diff.deletedObjects);
  XCTAssert(diff.insertedObjects.count == 0, @"expected zero insertions, got %@",
            diff.insertedObjects);
  XCTAssert(diff.changedObjects.count == 0, @"expected zero changes, got %@", diff.changedObjects);
  XCTAssert(diff.movedObjects.count == 0, @"expected zero moves, got %@", diff.movedObjects);

  initial = @[];
  result = @[[FUIDocumentSnapshot documentWithID:@"a"], [FUIDocumentSnapshot documentWithID:@"b"]];
  diff = [[FUISnapshotArrayDiff alloc] initWithInitialArray:initial
                                                resultArray:result];
  expectedDeletions = @[];
  expectedInsertions =
      @[[FUIDocumentSnapshot documentWithID:@"a"], [FUIDocumentSnapshot documentWithID:@"b"]];
  expectedMoves = @[];
  expectedChanges = @[];
  XCTAssertEqualObjects(diff.deletedObjects, expectedDeletions,
                        @"expected deletions to equal %@, got %@",
                        expectedDeletions, diff.deletedObjects);
  XCTAssertEqualObjects(diff.insertedObjects, expectedInsertions,
                        @"expected insertions to equal %@, got %@",
                        expectedInsertions, diff.insertedObjects);
  XCTAssertEqualObjects(diff.movedObjects, expectedMoves,
                        @"expected moves to equal %@, got %@",
                        expectedMoves, diff.movedObjects);
  XCTAssertEqualObjects(diff.changedObjects, expectedChanges,
                        @"expected deletions to equal %@, got %@",
                        expectedChanges, diff.changedObjects);

  initial = @[[FUIDocumentSnapshot documentWithID:@"x"], [FUIDocumentSnapshot documentWithID:@"y"]];
  result = @[[FUIDocumentSnapshot documentWithID:@"a"], [FUIDocumentSnapshot documentWithID:@"b"]];
  diff = [[FUISnapshotArrayDiff alloc] initWithInitialArray:initial
                                                resultArray:result];
  expectedDeletions = @[];
  expectedInsertions = @[];
  expectedMoves = @[];
  expectedChanges =
      @[[FUIDocumentSnapshot documentWithID:@"a"], [FUIDocumentSnapshot documentWithID:@"b"]];
  XCTAssertEqualObjects(diff.deletedObjects, expectedDeletions,
                        @"expected deletions to equal %@, got %@",
                        expectedDeletions, diff.deletedObjects);
  XCTAssertEqualObjects(diff.insertedObjects, expectedInsertions,
                        @"expected insertions to equal %@, got %@",
                        expectedInsertions, diff.insertedObjects);
  XCTAssertEqualObjects(diff.movedObjects, expectedMoves,
                        @"expected moves to equal %@, got %@",
                        expectedMoves, diff.movedObjects);
  XCTAssertEqualObjects(diff.changedObjects, expectedChanges,
                        @"expected deletions to equal %@, got %@",
                        expectedChanges, diff.changedObjects);

  initial = @[[FUIDocumentSnapshot documentWithID:@"b"], [FUIDocumentSnapshot documentWithID:@"a"]];
  result = @[[FUIDocumentSnapshot documentWithID:@"a"], [FUIDocumentSnapshot documentWithID:@"b"]];
  diff = [[FUISnapshotArrayDiff alloc] initWithInitialArray:initial
                                                resultArray:result];
  expectedDeletions = @[];
  expectedInsertions = @[];
  expectedMoves =
      @[[FUIDocumentSnapshot documentWithID:@"b"], [FUIDocumentSnapshot documentWithID:@"a"]];
  expectedChanges = @[];
  XCTAssertEqualObjects(diff.deletedObjects, expectedDeletions,
                        @"expected deletions to equal %@, got %@",
                        expectedDeletions, diff.deletedObjects);
  XCTAssertEqualObjects(diff.insertedObjects, expectedInsertions,
                        @"expected insertions to equal %@, got %@",
                        expectedInsertions, diff.insertedObjects);
  XCTAssertEqualObjects(diff.movedObjects, expectedMoves,
                        @"expected moves to equal %@, got %@",
                        expectedMoves, diff.movedObjects);
  XCTAssertEqualObjects(diff.changedObjects, expectedChanges,
                        @"expected deletions to equal %@, got %@",
                        expectedChanges, diff.changedObjects);

  initial = @[
    [FUIDocumentSnapshot documentWithID:@"a"],
    [FUIDocumentSnapshot documentWithID:@"a"],
    [FUIDocumentSnapshot documentWithID:@"a"],
    [FUIDocumentSnapshot documentWithID:@"a"]
  ];
  result = @[
    [FUIDocumentSnapshot documentWithID:@"a"],
    [FUIDocumentSnapshot documentWithID:@"a"],
    [FUIDocumentSnapshot documentWithID:@"a"],
    [FUIDocumentSnapshot documentWithID:@"a"]
  ];
  diff = [[FUISnapshotArrayDiff alloc] initWithInitialArray:initial
                                                resultArray:result];
  expectedDeletions = @[];
  expectedInsertions = @[];
  expectedMoves = @[];
  expectedChanges = @[];
  XCTAssertEqualObjects(diff.deletedObjects, expectedDeletions,
                        @"expected deletions to equal %@, got %@",
                        expectedDeletions, diff.deletedObjects);
  XCTAssertEqualObjects(diff.insertedObjects, expectedInsertions,
                        @"expected insertions to equal %@, got %@",
                        expectedInsertions, diff.insertedObjects);
  XCTAssertEqualObjects(diff.movedObjects, expectedMoves,
                        @"expected moves to equal %@, got %@",
                        expectedMoves, diff.movedObjects);
  XCTAssertEqualObjects(diff.changedObjects, expectedChanges,
                        @"expected deletions to equal %@, got %@",
                        expectedChanges, diff.changedObjects);
}

- (void)testDiffGeneralCases {
  NSArray *initial = @[
    [FUIDocumentSnapshot documentWithID:@"b"],
    [FUIDocumentSnapshot documentWithID:@"a"],
    [FUIDocumentSnapshot documentWithID:@"c"],
    [FUIDocumentSnapshot documentWithID:@"x"],
    [FUIDocumentSnapshot documentWithID:@"y"],
    [FUIDocumentSnapshot documentWithID:@"z"],
    [FUIDocumentSnapshot documentWithID:@"o"]
  ];
  NSArray *result = @[
    [FUIDocumentSnapshot documentWithID:@"a"],
    [FUIDocumentSnapshot documentWithID:@"b"],
    [FUIDocumentSnapshot documentWithID:@"c"],
    [FUIDocumentSnapshot documentWithID:@"z"],
    [FUIDocumentSnapshot documentWithID:@"x"],
    [FUIDocumentSnapshot documentWithID:@"y"],
    [FUIDocumentSnapshot documentWithID:@"v"],
    [FUIDocumentSnapshot documentWithID:@"h"]
  ];
  FUISnapshotArrayDiff *diff = [[FUISnapshotArrayDiff alloc] initWithInitialArray:initial
                                                                      resultArray:result];
  NSArray *expectedDeletions = @[];
  NSArray *expectedInsertions = @[[FUIDocumentSnapshot documentWithID:@"h"]];
  NSArray *expectedMoves = @[
    [FUIDocumentSnapshot documentWithID:@"b"],
    [FUIDocumentSnapshot documentWithID:@"a"],
    [FUIDocumentSnapshot documentWithID:@"x"],
    [FUIDocumentSnapshot documentWithID:@"y"],
    [FUIDocumentSnapshot documentWithID:@"z"]
  ];
  NSArray *expectedChanges = @[[FUIDocumentSnapshot documentWithID:@"v"]];
  XCTAssertEqualObjects(diff.deletedObjects, expectedDeletions,
                        @"expected deletions to equal %@, got %@",
                        expectedDeletions, diff.deletedObjects);
  XCTAssertEqualObjects(diff.insertedObjects, expectedInsertions,
                        @"expected insertions to equal %@, got %@",
                        expectedInsertions, diff.insertedObjects);
  XCTAssertEqualObjects(diff.movedObjects, expectedMoves,
                        @"expected moves to equal %@, got %@",
                        expectedMoves, diff.movedObjects);
  XCTAssertEqualObjects(diff.changedObjects, expectedChanges,
                        @"expected deletions to equal %@, got %@",
                        expectedChanges, diff.changedObjects);
}

#pragma mark - Diff with Firestore

- (void)testSimpleInsertionCase {
  NSArray *initial = @[];
  NSArray *result = @[
    [FUIDocumentSnapshot documentWithID:@"a"],
    [FUIDocumentSnapshot documentWithID:@"b"],
    [FUIDocumentSnapshot documentWithID:@"c"],
    [FUIDocumentSnapshot documentWithID:@"d"],
    [FUIDocumentSnapshot documentWithID:@"e"],
    [FUIDocumentSnapshot documentWithID:@"f"],
    [FUIDocumentSnapshot documentWithID:@"g"],
    [FUIDocumentSnapshot documentWithID:@"h"],
    [FUIDocumentSnapshot documentWithID:@"i"],
    [FUIDocumentSnapshot documentWithID:@"j"],
    [FUIDocumentSnapshot documentWithID:@"k"],
    [FUIDocumentSnapshot documentWithID:@"l"],
    [FUIDocumentSnapshot documentWithID:@"m"],
    [FUIDocumentSnapshot documentWithID:@"n"],
  ];

  NSMutableArray *changes = [NSMutableArray arrayWithCapacity:14];
  for (NSInteger i = 0; i < 14; i++) {
    FUIDocumentChange *change = [FUIDocumentChange changeWithType:FIRDocumentChangeTypeAdded
                                                         document:result[i]];
    [changes addObject:change];
  }

  FUISnapshotArrayDiff *diff = [[FUISnapshotArrayDiff alloc] initWithInitialArray:initial
                                                                      resultArray:result
                                                                  documentChanges:changes];

  NSArray *expectedDeletions = @[];
  NSArray *expectedInsertions = result;
  NSArray *expectedMoves = @[];
  NSArray *expectedChanges = @[];
  XCTAssertEqualObjects(diff.deletedObjects, expectedDeletions,
                        @"expected deletions to equal %@, got %@",
                        expectedDeletions, diff.deletedObjects);
  XCTAssertEqualObjects(diff.insertedObjects, expectedInsertions,
                        @"expected insertions to equal %@, got %@",
                        expectedInsertions, diff.insertedObjects);
  XCTAssertEqualObjects(diff.movedObjects, expectedMoves,
                        @"expected moves to equal %@, got %@",
                        expectedMoves, diff.movedObjects);
  XCTAssertEqualObjects(diff.changedObjects, expectedChanges,
                        @"expected deletions to equal %@, got %@",
                        expectedChanges, diff.changedObjects);
}

- (void)testSimpleChangeCase {
  NSArray *initial = @[
    [FUIDocumentSnapshot documentWithID:@"a"],
    [FUIDocumentSnapshot documentWithID:@"b"],
    [FUIDocumentSnapshot documentWithID:@"c"],
    [FUIDocumentSnapshot documentWithID:@"d"],
    [FUIDocumentSnapshot documentWithID:@"e"],
    [FUIDocumentSnapshot documentWithID:@"f"],
    [FUIDocumentSnapshot documentWithID:@"g"],
    [FUIDocumentSnapshot documentWithID:@"h"],
    [FUIDocumentSnapshot documentWithID:@"i"],
    [FUIDocumentSnapshot documentWithID:@"j"],
    [FUIDocumentSnapshot documentWithID:@"k"],
    [FUIDocumentSnapshot documentWithID:@"l"],
    [FUIDocumentSnapshot documentWithID:@"m"],
    [FUIDocumentSnapshot documentWithID:@"n"],
  ];

  NSArray *result = initial;

  NSMutableArray *changes = [NSMutableArray arrayWithCapacity:14];
  for (NSInteger i = 0; i < 14; i++) {
    FUIDocumentChange *change = [FUIDocumentChange changeWithType:FIRDocumentChangeTypeModified
                                                         document:result[i]];
    [changes addObject:change];
  }

  FUISnapshotArrayDiff *diff = [[FUISnapshotArrayDiff alloc] initWithInitialArray:initial
                                                                      resultArray:result
                                                                  documentChanges:changes];

  NSArray *expectedDeletions = @[];
  NSArray *expectedInsertions = @[];
  NSArray *expectedMoves = @[];
  NSArray *expectedChanges = initial;
  XCTAssertEqualObjects(diff.deletedObjects, expectedDeletions,
                        @"expected deletions to equal %@, got %@",
                        expectedDeletions, diff.deletedObjects);
  XCTAssertEqualObjects(diff.insertedObjects, expectedInsertions,
                        @"expected insertions to equal %@, got %@",
                        expectedInsertions, diff.insertedObjects);
  XCTAssertEqualObjects(diff.movedObjects, expectedMoves,
                        @"expected moves to equal %@, got %@",
                        expectedMoves, diff.movedObjects);
  XCTAssertEqualObjects(diff.changedObjects, expectedChanges,
                        @"expected deletions to equal %@, got %@",
                        expectedChanges, diff.changedObjects);
}

- (void)testSimpleDeletionCase {
  NSArray *initial = @[
    [FUIDocumentSnapshot documentWithID:@"a"],
    [FUIDocumentSnapshot documentWithID:@"b"],
    [FUIDocumentSnapshot documentWithID:@"c"],
    [FUIDocumentSnapshot documentWithID:@"d"],
    [FUIDocumentSnapshot documentWithID:@"e"],
    [FUIDocumentSnapshot documentWithID:@"f"],
    [FUIDocumentSnapshot documentWithID:@"g"],
    [FUIDocumentSnapshot documentWithID:@"h"],
    [FUIDocumentSnapshot documentWithID:@"i"],
    [FUIDocumentSnapshot documentWithID:@"j"],
    [FUIDocumentSnapshot documentWithID:@"k"],
    [FUIDocumentSnapshot documentWithID:@"l"],
    [FUIDocumentSnapshot documentWithID:@"m"],
    [FUIDocumentSnapshot documentWithID:@"n"],
  ];
  NSArray *result = @[];

  NSMutableArray *changes = [NSMutableArray arrayWithCapacity:14];
  for (NSInteger i = 0; i < 14; i++) {
    FUIDocumentChange *change = [FUIDocumentChange changeWithType:FIRDocumentChangeTypeRemoved
                                                         document:initial[i]];
    [changes addObject:change];
  }

  FUISnapshotArrayDiff *diff = [[FUISnapshotArrayDiff alloc] initWithInitialArray:initial
                                                                      resultArray:result
                                                                  documentChanges:changes];

  NSArray *expectedDeletions = initial;
  NSArray *expectedInsertions = @[];
  NSArray *expectedMoves = @[];
  NSArray *expectedChanges = @[];
  XCTAssertEqualObjects(diff.deletedObjects, expectedDeletions,
                        @"expected deletions to equal %@, got %@",
                        expectedDeletions, diff.deletedObjects);
  XCTAssertEqualObjects(diff.insertedObjects, expectedInsertions,
                        @"expected insertions to equal %@, got %@",
                        expectedInsertions, diff.insertedObjects);
  XCTAssertEqualObjects(diff.movedObjects, expectedMoves,
                        @"expected moves to equal %@, got %@",
                        expectedMoves, diff.movedObjects);
  XCTAssertEqualObjects(diff.changedObjects, expectedChanges,
                        @"expected deletions to equal %@, got %@",
                        expectedChanges, diff.changedObjects);
}

@end
