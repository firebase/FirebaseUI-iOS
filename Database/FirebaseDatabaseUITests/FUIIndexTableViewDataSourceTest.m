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

#import "FUIIndexTableViewDataSource.h"
#import "FUIDatabaseTestUtils.h"

static NSString *const kTestReuseIdentifier = @"FUIIndexTableViewDataSourceTest";

@interface FUIIndexTableViewDataSourceTest : XCTestCase <FUIIndexTableViewDataSourceDelegate>

@property (nonatomic, readwrite) FUIIndexTableViewDataSource *dataSource;

@property (nonatomic, readwrite) UITableView *tableView;

@property (nonatomic, readwrite) FUITestObservable *index;
@property (nonatomic, readwrite) FUITestObservable *data;

@property (nonatomic, readwrite) NSMutableDictionary *dict;

@end

@implementation FUIIndexTableViewDataSourceTest

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
  self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)
                                                style:UITableViewStylePlain];
  [self.tableView registerClass:[UITableViewCell class]
         forCellReuseIdentifier:kTestReuseIdentifier];

  self.index = [[FUITestObservable alloc] initWithDictionary:database()[@"index"]];
  self.data = [[FUITestObservable alloc] initWithDictionary:database()[@"data"]];
  self.dataSource = [self.tableView bindToIndexedQuery:(FIRDatabaseQuery *)self.index
                                                  data:(FIRDatabaseReference *)self.data
                                              delegate:self
                                          populateCell:^UITableViewCell *(UITableView *view,
                                                                          NSIndexPath *indexPath,
                                                                          FIRDataSnapshot *snap) {
    UITableViewCell *cell = [view dequeueReusableCellWithIdentifier:kTestReuseIdentifier];
    cell.accessibilityLabel = snap.key;
    cell.accessibilityValue = snap.value;
    return cell;
  }];
  self.dict = [database() mutableCopy];
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
  UITableViewCell *cell = [self.dataSource tableView:self.tableView
                               cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];

  XCTAssertEqualObjects(cell.accessibilityLabel, @"data");
  XCTAssertEqualObjects(cell.accessibilityValue, @"1");

  cell = [self.dataSource tableView:self.tableView
              cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];

  XCTAssertEqualObjects(cell.accessibilityLabel, @"data");
  XCTAssertEqualObjects(cell.accessibilityValue, @"2");

  cell = [self.dataSource tableView:self.tableView
              cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];

  XCTAssertEqualObjects(cell.accessibilityLabel, @"data");
  XCTAssertEqualObjects(cell.accessibilityValue, @"3");
}

- (void)testItUpdatesOnInsertion {
  // insert item
  [self.data addObject:@{ @"data": @"4" } forKey:@"4"];
  [self.index addObject:@(YES) forKey:@"4"];

  UITableViewCell *cell = [self.dataSource tableView:self.tableView
                               cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];

  XCTAssertEqualObjects(cell.accessibilityLabel, @"data");
  XCTAssertEqualObjects(cell.accessibilityValue, @"4");
}

- (void)testItUpdatesOnDeletion {
  // delete item
  [self.data removeObjectForKey:@"2"];
  [self.index removeObjectForKey:@"2"];

  UITableViewCell *cell = [self.dataSource tableView:self.tableView
                               cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];

  XCTAssertEqualObjects(cell.accessibilityLabel, @"data");
  XCTAssertEqualObjects(cell.accessibilityValue, @"3");
}

- (void)testItUpdatesOnChange {
  // change item
  [self.data changeObject:@{ @"data": @"changed" } forKey:@"2"];
  [self.index changeObject:@(YES) forKey:@"2"];

  UITableViewCell *cell = [self.dataSource tableView:self.tableView
                               cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];

  XCTAssertEqualObjects(cell.accessibilityLabel, @"data");
  XCTAssertEqualObjects(cell.accessibilityValue, @"changed");
}

- (void)testItUpdatesOnMove {
  // move item to back
  [self.data moveObjectFromIndex:0 toIndex:2];
  [self.index moveObjectFromIndex:0 toIndex:2];

  UITableViewCell *cell = [self.dataSource tableView:self.tableView
                               cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];

  XCTAssertEqualObjects(cell.accessibilityLabel, @"data");
  XCTAssertEqualObjects(cell.accessibilityValue, @"1");

  // move item to front
  [self.data moveObjectFromIndex:2 toIndex:0];
  [self.index moveObjectFromIndex:2 toIndex:0];

  cell = [self.dataSource tableView:self.tableView
              cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];

  XCTAssertEqualObjects(cell.accessibilityLabel, @"data");
  XCTAssertEqualObjects(cell.accessibilityValue, @"3");
}

- (void)testItReturnsSnapshotsFromItsIndexArray {
  FIRDataSnapshot *snap = [self.dataSource snapshotAtIndex:0];
  XCTAssertEqualObjects(snap.key, @"data", @"expected snap's key to equal 'data', got %@ instead", snap.key);
  XCTAssertEqualObjects(snap.value, @"1", @"expected snap's key to equal '1', got %@ instead", snap.value);
}

@end
