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

#import "FirebaseArrayTestUtils.h"
#import "FirebaseIndexArray.h"

@interface FirebaseIndexArrayTest : XCTestCase
@property (nonatomic) FUITestObservable *index;
@property (nonatomic) FUITestObservable *data;
@property (nonatomic) FirebaseIndexArray *array;
@end

@implementation FirebaseIndexArrayTest

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
  self.array = [[FirebaseIndexArray alloc] initWithIndex:self.index
                                                    data:self.data];
}

- (void)tearDown {
  [super tearDown];
  [self.array invalidate];
  self.array = nil;
}

- (void)testExample {
  NSArray *items = self.array.items;
  XCTAssert(items.count == 3, @"expected %i keys, got %li", 3, items.count);
}

@end
