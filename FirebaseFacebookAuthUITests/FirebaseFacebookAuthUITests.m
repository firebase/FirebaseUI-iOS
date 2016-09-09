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
@import FirebaseFacebookAuthUI;

@interface FirebaseFacebookAuthUITests : XCTestCase
@property (nonatomic, strong) FIRFacebookAuthUI *provider;
@end

@implementation FirebaseFacebookAuthUITests

- (void)setUp {
  [super setUp];
  self.provider = [[FIRFacebookAuthUI alloc] initWithAppID:@"an id"];
}

- (void)testItExists {
  XCTAssert(self.provider != nil);
}

@end
