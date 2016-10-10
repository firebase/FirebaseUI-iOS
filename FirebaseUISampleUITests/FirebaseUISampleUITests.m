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

#import <XCTest/XCTest.h>

@interface FirebaseUISampleUITests : XCTestCase

@end

@implementation FirebaseUISampleUITests

- (void)setUp {
    [super setUp];
    self.continueAfterFailure = NO;
    [[[XCUIApplication alloc] init] launch];
}

- (void)testEmailProviderEnterEmail {
  XCUIApplication *app = [[XCUIApplication alloc] init];
  [app.buttons[@"Sign In"] tap];
  [app.buttons[@"EmailButtonAccessibilityID"] tap];
  
  XCUIElementQuery *tablesQuery = app.tables;
  [tablesQuery.cells[@"EmailCellAccessibilityID"].textFields[@"Enter your email"] tap];
  [[tablesQuery.cells[@"EmailCellAccessibilityID"] childrenMatchingType:XCUIElementTypeTextField].element typeText:@"test@test.com"];
  
  XCUIElement *signInWithEmailNavigationBar = app.navigationBars[@"Sign in with email"];
  [signInWithEmailNavigationBar.buttons[@"NextButtonAccessibilityID"] tap];
  [tablesQuery.buttons[@"Trouble signing in?"] tap];
  [[[[app.navigationBars[@"Recover password"] childrenMatchingType:XCUIElementTypeButton] matchingIdentifier:@"Back"] elementBoundByIndex:0] tap];
  [[[[app.navigationBars[@"Sign in"] childrenMatchingType:XCUIElementTypeButton] matchingIdentifier:@"Back"] elementBoundByIndex:0] tap];
  [[[[signInWithEmailNavigationBar childrenMatchingType:XCUIElementTypeButton] matchingIdentifier:@"Back"] elementBoundByIndex:0] tap];
  [app.navigationBars[@"Welcome"].buttons[@"Cancel"] tap];
  [app.alerts[@"Error"].buttons[@"Close"] tap];
}

@end
