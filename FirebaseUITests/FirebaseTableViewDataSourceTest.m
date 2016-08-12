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

#import "FirebaseTableViewDataSource.h"
#import "FirebaseArrayTestUtils.h"

static NSString *const kTestReuseIdentifier = @"FirebaseTableViewDataSourceTest";

@interface FirebaseTableViewDataSourceTest : XCTestCase
@property (nonatomic) UITableView *tableView;
@property (nonatomic) FUITestObservable *observable;
@property (nonatomic) FirebaseTableViewDataSource *dataSource;
@end

@implementation FirebaseTableViewDataSourceTest

- (void)setUp {
  [super setUp];
  [UIView setAnimationsEnabled:NO];
  self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)
                                                style:UITableViewStylePlain];
  [self.tableView registerClass:[UITableViewCell class]
         forCellReuseIdentifier:kTestReuseIdentifier];
  
  self.observable = [[FUITestObservable alloc] init];
  // Horrible abuse of type system, knowing that the initializer passes the observable straight to
  // FirebaseArray anyway.
  self.dataSource = [[FirebaseTableViewDataSource alloc] initWithRef:(FIRDatabaseReference *)self.observable
                                                 cellReuseIdentifier:kTestReuseIdentifier
                                                                view:self.tableView];
  [self.dataSource populateCellWithBlock:^(__kindof UITableViewCell *_Nonnull cell,
                                           FUIFakeSnapshot * _Nonnull object) {
    cell.accessibilityValue = object.key;
  }];
  self.tableView.dataSource = self.dataSource;
  
  [self.observable populateWithCount:10];
}

- (void)tearDown {
  [super tearDown];
  [self.observable removeAllObservers];
  [UIView setAnimationsEnabled:YES];
}

- (void)testItHasACount {
  NSUInteger count = self.dataSource.count;
  XCTAssert(count == 10, @"expected data source to have 10 elements after 10 insertions, but got %lu", count);
}

- (void)testItPopulatesCells {
  UITableViewCell *cell = [self.dataSource tableView:self.tableView
                               cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0]];
  
  XCTAssert([cell.accessibilityValue isEqualToString:@"5"], @"expected cell to have accessibility label \
            equal to its indexpath row (5), but instead got %@", cell.accessibilityValue);
}

- (void)testItInsertsCells {
  FUIFakeSnapshot *snap = [[FUIFakeSnapshot alloc] init];
  snap.key = @"inserted";
  [self.observable sendEvent:FIRDataEventTypeChildAdded withObject:snap previousKey:@"9" error:nil];
  
  UITableViewCell *cell = [self.dataSource tableView:self.tableView
                               cellForRowAtIndexPath:[NSIndexPath indexPathForRow:10 inSection:0]];
  XCTAssert([cell.accessibilityValue isEqualToString:snap.key], @"expected inserted element to be last \
            cell in table view, instead got %@", cell.accessibilityValue);
}

- (void)testItDeletesCells {
  FUIFakeSnapshot *snap = [[FUIFakeSnapshot alloc] init];
  snap.key = @"9";
  [self.observable sendEvent:FIRDataEventTypeChildRemoved withObject:snap previousKey:@"8" error:nil];
  
  UITableViewCell *cell = [self.dataSource tableView:self.tableView
                               cellForRowAtIndexPath:[NSIndexPath indexPathForRow:8 inSection:0]];
  XCTAssert([cell.accessibilityValue isEqualToString:@"8"], @"expected second-to-last element to be last \
            after deletion of last element, instead got %@", cell.accessibilityValue);
  XCTAssert(self.dataSource.count == 9, @"expected 10-element data source to have 9 elements after deletion, \
            instead got %lu", self.dataSource.count);
}

// TODO: add tests for moving and modifying elements

@end
