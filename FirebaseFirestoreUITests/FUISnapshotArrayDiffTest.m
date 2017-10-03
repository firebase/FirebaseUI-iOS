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

#pragma mark - FUILCS

// TODO(morganchen): add indexes to these tests too
- (void)testLCSEdgeCases {
  NSArray *initial = @[];
  NSArray *result = @[];

  NSArray *lcs = [FUILCS lcsWithInitialArray:initial resultArray:result];

  XCTAssertEqualObjects(lcs, @[], @"Expected LCS of 2 empty arrays to be empty array");

  initial = @[@"a", @"b", @"c", @"d", @"e"];
  result = @[@"a", @"b", @"c"];

  lcs = [FUILCS lcsWithInitialArray:initial resultArray:result];

  NSArray *expected = @[@"a", @"b", @"c"];
  XCTAssertEqualObjects(lcs, expected, @"Expected lcs of %@ and %@ to be %@, got %@",
                        initial, result, expected, lcs);

  initial = @[@"a", @"b", @"c", @"d", @"e"];
  result = @[@"c", @"d", @"e"];

  lcs = [FUILCS lcsWithInitialArray:initial resultArray:result];

  expected = @[@"c", @"d", @"e"];
  XCTAssertEqualObjects(lcs, expected, @"Expected lcs of %@ and %@ to be %@, got %@",
                        initial, result, expected, lcs);

  initial = @[@"a", @"b", @"c", @"d", @"e"];
  result = @[@"c", @"c", @"c"];

  lcs = [FUILCS lcsWithInitialArray:initial resultArray:result];

  expected = @[@"c"];
  XCTAssertEqualObjects(lcs, expected, @"Expected lcs of %@ and %@ to be %@, got %@",
                        initial, result, expected, lcs);

  initial = @[@"a", @"e"];
  result = @[@"a", @"b", @"c", @"d", @"e"];

  lcs = [FUILCS lcsWithInitialArray:initial resultArray:result];

  expected = @[@"a", @"e"];
  XCTAssertEqualObjects(lcs, expected, @"Expected lcs of %@ and %@ to be %@, got %@",
                        initial, result, expected, lcs);

  initial = @[@"a", @"b", @"c", @"d", @"e"];
  result = @[@"x", @"y", @"z", @"z", @"f"];

  lcs = [FUILCS lcsWithInitialArray:initial resultArray:result];

  expected = @[];
  XCTAssertEqualObjects(lcs, expected, @"Expected lcs of %@ and %@ to be %@, got %@",
                        initial, result, expected, lcs);

  initial = @[@"a", @"b", @"c", @"d", @"e"];
  result = @[@"a", @"b", @"c", @"d", @"e"];

  lcs = [FUILCS lcsWithInitialArray:initial resultArray:result];

  expected = @[@"a", @"b", @"c", @"d", @"e"];
  XCTAssertEqualObjects(lcs, expected, @"Expected lcs of %@ and %@ to be %@, got %@",
                        initial, result, expected, lcs);

  initial = @[@"a", @"b", @"d", @"e"];
  result = @[@"a", @"b", @"c", @"d", @"e"];

  lcs = [FUILCS lcsWithInitialArray:initial resultArray:result];

  expected = @[@"a", @"b", @"d", @"e"];
  XCTAssertEqualObjects(lcs, expected, @"Expected lcs of %@ and %@ to be %@, got %@",
                        initial, result, expected, lcs);
}

- (void)testLCSGeneralCases {
  NSArray *initial, *result, *lcs, *expected;

  initial = [@"a b a b a b a a a c b c" componentsSeparatedByString:@" "];
  result = [@"b a b a c a c a c b c" componentsSeparatedByString:@" "];

  lcs = [FUILCS lcsWithInitialArray:initial resultArray:result];

  expected = @[@"b", @"a", @"b", @"a", @"a", @"a", @"c", @"b", @"c"];
  XCTAssertEqualObjects(lcs, expected, @"Expected lcs of %@ and %@ to be %@, got %@",
                        initial, result, expected, lcs);
}

#pragma mark - General diff (without Firestore)

- (void)testDiffEdgeCases {
  NSArray *initial = @[];
  NSArray *result = @[];

  FUISnapshotArrayDiff *diff = [[FUISnapshotArrayDiff alloc] initWithInitialArray:initial
                                                                      resultArray:result];

  XCTAssert(diff.deletedObjects.count == 0, @"expected diff between empty arrays to be empty");
  XCTAssert(diff.insertedObjects.count == 0, @"expected diff between empty arrays to be empty");
  XCTAssert(diff.changedObjects.count == 0, @"expected diff between empty arrays to be empty");
  XCTAssert(diff.movedObjects.count == 0, @"expected diff between empty arrays to be empty");

  initial = @[@"a", @"b"];
  result = @[];
  diff = [[FUISnapshotArrayDiff alloc] initWithInitialArray:initial
                                                resultArray:result];

  NSArray *expectedDeletions, *expectedInsertions, *expectedChanges, *expectedMoves;
  expectedDeletions = @[@"a", @"b"];
  XCTAssertEqualObjects(diff.deletedObjects, expectedDeletions,
                        @"expected deletions to equal %@, got %@",
                        expectedDeletions, diff.deletedObjects);
  XCTAssert(diff.insertedObjects.count == 0, @"expected zero insertions, got %@",
            diff.insertedObjects);
  XCTAssert(diff.changedObjects.count == 0, @"expected zero changes, got %@", diff.changedObjects);
  XCTAssert(diff.movedObjects.count == 0, @"expected zero moves, got %@", diff.movedObjects);

  initial = @[];
  result = @[@"a", @"b"];
  diff = [[FUISnapshotArrayDiff alloc] initWithInitialArray:initial
                                                resultArray:result];
  expectedDeletions = @[];
  expectedInsertions = @[@"a", @"b"];
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

  initial = @[@"x", @"y"];
  result = @[@"a", @"b"];
  diff = [[FUISnapshotArrayDiff alloc] initWithInitialArray:initial
                                                resultArray:result];
  expectedDeletions = @[@"x", @"y"];
  expectedInsertions = @[@"a", @"b"];
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

  initial = @[@"b", @"a"];
  result = @[@"a", @"b"];
  diff = [[FUISnapshotArrayDiff alloc] initWithInitialArray:initial
                                                resultArray:result];
  expectedDeletions = @[];
  expectedInsertions = @[];
  expectedMoves = @[@"a"];
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

  initial = @[@"a", @"a", @"a", @"a"];
  result = @[@"a", @"a", @"a", @"a"];
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
  NSArray *initial = @[@"b", @"a", @"c", @"x", @"y", @"z", @"o"];
  NSArray *result = @[@"a", @"b", @"c", @"z", @"x", @"y", @"b", @"h"];
  FUISnapshotArrayDiff *diff = [[FUISnapshotArrayDiff alloc] initWithInitialArray:initial
                                                resultArray:result];
  NSArray *expectedDeletions = @[@"o"];
  NSArray *expectedInsertions = @[@"b", @"h"];
  NSArray *expectedMoves = @[@"a", @"z"];
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

#pragma mark - Diff with Firestore

- (void)testSimpleInsertionCase {
  NSArray *initial = @[];
  NSArray *result =
      @[@"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n"];

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
  NSArray *initial =
      @[@"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n"];
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
  NSArray *initial =
      @[@"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n"];
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
