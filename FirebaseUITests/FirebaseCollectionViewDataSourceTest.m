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
  self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                           collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
  [self.collectionView registerClass:[UICollectionViewCell class]
          forCellWithReuseIdentifier:kTestReuseIdentifier];
  self.observable = [[FUITestObservable alloc] init];
  // Horrible abuse of type system, knowing that the initializer passes the observable straight to
  // FirebaseArray anyway.
  self.dataSource = [[FirebaseCollectionViewDataSource alloc] initWithRef:(FIRDatabaseReference *)self.observable
                                                      cellReuseIdentifier:kTestReuseIdentifier
                                                                          // no really nil is ok.
                                                                          // using nil here because UICollectionView
                                                                          // gets unhappy sometimes
                                                                     view:(UICollectionView *_Nonnull)nil];
  [self.observable populateWithCount:10];
}

- (void)tearDown {
  [super tearDown];
}

- (void)testItHasACount {
  NSUInteger count = self.dataSource.count;
  XCTAssert(count == 10, @"expected data source to have 10 elements after 10 insertions, but got %lu", count);
}

@end
