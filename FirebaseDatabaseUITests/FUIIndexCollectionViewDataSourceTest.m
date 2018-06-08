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
@import UIKit;

@import FirebaseDatabaseUI;

#import "FUIIndexCollectionViewDataSource.h"
#import "FUIDatabaseTestUtils.h"

static NSString *const kTestReuseIdentifier = @"FUIIndexCollectionViewDataSourceTest";

@interface FUIIndexCollectionViewDataSourceTest : XCTestCase <FUIIndexCollectionViewDataSourceDelegate>

@property (nonatomic, readwrite) FUIIndexCollectionViewDataSource *dataSource;

@property (nonatomic, readwrite) UICollectionView *collectionView;

@property (nonatomic, readwrite) FUITestObservable *index;
@property (nonatomic, readwrite) FUITestObservable *data;

@property (nonatomic, readwrite) NSMutableDictionary *dict;

@end

@implementation FUIIndexCollectionViewDataSourceTest

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
  [UIView setAnimationsEnabled:NO];
  self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)
                                           collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
  [self.collectionView registerClass:[UICollectionViewCell class]
          forCellWithReuseIdentifier:kTestReuseIdentifier];

  self.index = [[FUITestObservable alloc] initWithDictionary:database()[@"index"]];
  self.data = [[FUITestObservable alloc] initWithDictionary:database()[@"data"]];
  self.dataSource = [self.collectionView bindToIndexedQuery:(FIRDatabaseQuery *)self.index
                                                       data:(FIRDatabaseReference *)self.data
                                                   delegate:self
                                               populateCell:^UICollectionViewCell *(UICollectionView *view,
                                                                                    NSIndexPath * indexPath,
                                                                                    FIRDataSnapshot *snap) {
    UICollectionViewCell *cell = [view dequeueReusableCellWithReuseIdentifier:kTestReuseIdentifier
                                                                 forIndexPath:indexPath];
    cell.accessibilityLabel = snap.key;
    cell.accessibilityValue = snap.value;
    return cell;
  }];
  self.dict = [database() mutableCopy];

  // Removing this line causes the tests to crash.
  NSLog(@"count: %lu", [self.collectionView numberOfItemsInSection:0]);
}

- (void)tearDown {
  [UIView setAnimationsEnabled:YES];
  [super tearDown];
}

- (void)testItReturnsItsArraysIndexes {
  NSArray *expectedIndexes = @[
    [FUIFakeSnapshot snapWithKey:@"1" value:@(YES)],
    [FUIFakeSnapshot snapWithKey:@"2" value:@(YES)],
    [FUIFakeSnapshot snapWithKey:@"3" value:@(YES)],
  ];

  NSArray *indexes = self.dataSource.indexes;

  XCTAssert([indexes isEqual:expectedIndexes], @"expected data source's indexes to equal its array's indexes");
}

- (void)testItPopulatesCells {
  UICollectionViewCell *cell = [self.dataSource collectionView:self.collectionView
                                        cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];

  XCTAssertEqualObjects(cell.accessibilityLabel, @"data");
  XCTAssertEqualObjects(cell.accessibilityValue, @"1");

  cell = [self.dataSource collectionView:self.collectionView
                  cellForItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];

  XCTAssertEqualObjects(cell.accessibilityLabel, @"data");
  XCTAssertEqualObjects(cell.accessibilityValue, @"2");

  cell = [self.dataSource collectionView:self.collectionView
                  cellForItemAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:0]];

  XCTAssertEqualObjects(cell.accessibilityLabel, @"data");
  XCTAssertEqualObjects(cell.accessibilityValue, @"3");
}

- (void)testItUpdatesOnInsertion {
  // insert item
  [self.data addObject:@{ @"data": @"4" } forKey:@"4"];
  [self.index addObject:@(YES) forKey:@"4"];

  UICollectionViewCell *cell = [self.dataSource collectionView:self.collectionView
                                        cellForItemAtIndexPath:[NSIndexPath indexPathForItem:3 inSection:0]];

  XCTAssertEqualObjects(cell.accessibilityLabel, @"data");
  XCTAssertEqualObjects(cell.accessibilityValue, @"4");
}

- (void)testItUpdatesOnDeletion {
  // delete item
  [self.data removeObjectForKey:@"2"];
  [self.index removeObjectForKey:@"2"];

  UICollectionViewCell *cell = [self.dataSource collectionView:self.collectionView
                                        cellForItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];

  XCTAssertEqualObjects(cell.accessibilityLabel, @"data");
  XCTAssertEqualObjects(cell.accessibilityValue, @"3");
}

- (void)testItUpdatesOnChange {
  // change item
  [self.data changeObject:@{ @"data": @"changed" } forKey:@"2"];
  [self.index changeObject:@(YES) forKey:@"2"];

  UICollectionViewCell *cell = [self.dataSource collectionView:self.collectionView
                                        cellForItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];

  XCTAssertEqualObjects(cell.accessibilityLabel, @"data");
  XCTAssertEqualObjects(cell.accessibilityValue, @"changed");
}

- (void)testItUpdatesOnMove {
  // move item to back
  [self.data moveObjectFromIndex:0 toIndex:2];
  [self.index moveObjectFromIndex:0 toIndex:2];

  UICollectionViewCell *cell = [self.dataSource collectionView:self.collectionView
                                        cellForItemAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:0]];

  XCTAssertEqualObjects(cell.accessibilityLabel, @"data");
  XCTAssertEqualObjects(cell.accessibilityValue, @"1");

  // move item to front
  [self.data moveObjectFromIndex:2 toIndex:0];
  [self.index moveObjectFromIndex:2 toIndex:0];
  
  cell = [self.dataSource collectionView:self.collectionView
                  cellForItemAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:0]];
  
  XCTAssertEqualObjects(cell.accessibilityLabel, @"data");
  XCTAssertEqualObjects(cell.accessibilityValue, @"3");
}

- (void)testItReturnsSnapshotsFromItsIndexArray {
  FIRDataSnapshot *snap = [self.dataSource snapshotAtIndex:0];
  XCTAssertEqualObjects(snap.key, @"data", @"expected snap's key to equal 'data', got %@ instead", snap.key);
  XCTAssertEqualObjects(snap.value, @"1", @"expected snap's key to equal '1', got %@ instead", snap.value);
}

@end
