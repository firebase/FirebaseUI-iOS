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

#import "FirebaseCollectionViewDataSource.h"
#import "FirebaseArrayTestUtils.h"

static NSString *const kTestReuseIdentifier = @"FirebaseCollectionViewDataSourceTest";

@interface FirebaseCollectionViewDataSourceTest : XCTestCase
@property (nonatomic) UICollectionView *collectionView;
@property (nonatomic) FUITestObservable *observable;
@property (nonatomic) FirebaseCollectionViewDataSource *dataSource;
@end

@implementation FirebaseCollectionViewDataSourceTest

- (void)setUp {
  [super setUp];
  [UIView setAnimationsEnabled:NO];
  self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)
                                           collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
  [self.collectionView registerClass:[UICollectionViewCell class]
          forCellWithReuseIdentifier:kTestReuseIdentifier];
  
  self.observable = [[FUITestObservable alloc] init];
  // Horrible abuse of type system, knowing that the initializer passes the observable straight to
  // FirebaseArray anyway.
  self.dataSource = [[FirebaseCollectionViewDataSource alloc] initWithRef:(FIRDatabaseReference *)self.observable
                                                      cellReuseIdentifier:kTestReuseIdentifier
                                                                     view:self.collectionView];
  [self.dataSource populateCellWithBlock:^(__kindof UICollectionViewCell *_Nonnull cell,
                                           FUIFakeSnapshot * _Nonnull object) {
    cell.accessibilityValue = object.key;
  }];
  
  [self.observable populateWithCount:10];
  self.collectionView.dataSource = self.dataSource;
}

- (void)tearDown {
  [super tearDown];
  [self.observable removeAllObservers];
  [UIView setAnimationsEnabled:YES];
}

- (void)testItHasACount {
  NSUInteger count = self.dataSource.count;
  NSUInteger collectionViewCount = [self.collectionView numberOfItemsInSection:0];
  XCTAssert(collectionViewCount == 10,
            @"expected collection view to have 10 elements after 10 insertions, but got %lu", collectionViewCount);
  XCTAssert(count == 10, @"expected data source to have 10 elements after 10 insertions, but got %lu", count);
}

- (void)testItPopulatesCells {
  UICollectionViewCell *cell = [self.dataSource collectionView:self.collectionView
                                        cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
  XCTAssert([cell.accessibilityValue isEqualToString:@"0"],
            @"expected cellForItemAtIndexPath to populate accessibility label with value '0', \
            but instead got %@", cell.accessibilityValue);
  
  cell = [self.dataSource collectionView:self.collectionView
                  cellForItemAtIndexPath:[NSIndexPath indexPathForItem:5 inSection:0]];
  XCTAssert([cell.accessibilityValue isEqualToString:@"5"],
            @"expected cellForItemAtIndexPath to populate accessibility label with value '5', \
            but instead got %@", cell.accessibilityValue);
  
  cell = [self.dataSource collectionView:self.collectionView
                   cellForItemAtIndexPath:[NSIndexPath indexPathForItem:9 inSection:0]];
  XCTAssert([cell.accessibilityValue isEqualToString:@"9"],
            @"expected cellForItemAtIndexPath to populate accessibility label with value '9', \
            but instead got %@", cell.accessibilityValue);
}

- (void)testItDeletesCells {
  FUIFakeSnapshot *snap = [[FUIFakeSnapshot alloc] init];
  snap.key = @"0";
  [self.observable sendEvent:FIRDataEventTypeChildRemoved withObject:snap previousKey:nil error:nil];
  UICollectionViewCell *cell = [self.dataSource collectionView:self.collectionView
                                        cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
  XCTAssert([cell.accessibilityValue isEqualToString:@"1"], @"expected element with previous index 1 \
            to be zeroth after deletion of zeroth element, but got %@", cell.accessibilityValue);
}

- (void)testItMovesCells {
  FUIFakeSnapshot *snap = [[FUIFakeSnapshot alloc] init];
  snap.key = @"5";
  [self.observable sendEvent:FIRDataEventTypeChildMoved withObject:snap previousKey:@"3" error:nil];
  UICollectionViewCell *cell = [self.dataSource collectionView:self.collectionView
                                        cellForItemAtIndexPath:[NSIndexPath indexPathForItem:4 inSection:0]];
  
  XCTAssert([cell.accessibilityValue isEqualToString:@"5"], @"expected element with index 5 to move to index 4, \
            found %@ at index 4 instead", cell.accessibilityValue);
}

@end
