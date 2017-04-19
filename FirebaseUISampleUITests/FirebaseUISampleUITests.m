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

@implementation XCUIElement (ForceTap)
- (void) forceTap {
  if (self.hittable) {
    [self tap];
  } else {
    XCUICoordinate *coordinate = [self coordinateWithNormalizedOffset:CGVectorMake(0.0, 0.0)];
    [coordinate tap];
  }
}
@end

@interface FirebaseUISampleUITests : XCTestCase

@end

@implementation FirebaseUISampleUITests

- (void)setUp {
    [super setUp];
    self.continueAfterFailure = NO;
    [[[XCUIApplication alloc] init] launch];
}

- (void)testSuccesSignIn {
  XCUIApplication *app = [[XCUIApplication alloc] init];
  XCUIElementQuery *tablesQuery = app.tables;
  [tablesQuery.cells.staticTexts[@"Simulate Existing User"] tap];
  [app.toolbars.buttons[@"Sign In"] tap];
  [tablesQuery.cells[@"EmailCellAccessibilityID"].textFields[@"Enter your email"] tap];
  [[tablesQuery.cells[@"EmailCellAccessibilityID"] childrenMatchingType:XCUIElementTypeTextField].element typeText:@"test@test.com"];
  [app.navigationBars[@"Sign in with email"].buttons[@"NextButtonAccessibilityID"] tap];
  [tablesQuery.secureTextFields[@"Enter your password"] tap];
  [[[tablesQuery.cells containingType:XCUIElementTypeStaticText identifier:@"Password"] childrenMatchingType:XCUIElementTypeSecureTextField].element typeText:@"test"];
  [app.navigationBars[@"Sign in"].buttons[@"Sign in"] tap];
}

- (void)testSuccesSignUp {
  XCUIApplication *app = [[XCUIApplication alloc] init];
  XCUIElementQuery *tablesQuery = app.tables;
  [tablesQuery.staticTexts[@"Simulate New User"] tap];
  [app.toolbars.buttons[@"Sign In"] tap];
  
  [tablesQuery.cells[@"EmailCellAccessibilityID"].textFields[@"Enter your email"] tap];
  [[tablesQuery.cells[@"EmailCellAccessibilityID"] childrenMatchingType:XCUIElementTypeTextField].element typeText:@"test2@test2.com"];
  [app.navigationBars[@"Sign in with email"].buttons[@"NextButtonAccessibilityID"] tap];
  [tablesQuery.cells[@"NameSignUpCellAccessibilityID"].textFields[@"First & last name"] tap];
  [[tablesQuery.cells[@"NameSignUpCellAccessibilityID"] childrenMatchingType:XCUIElementTypeTextField].element typeText:@"test2"];
  
  [tablesQuery.cells[@"PasswordSignUpCellAccessibilityID"].secureTextFields[@"Choose password"] tap];
  [[tablesQuery.secureTextFields containingType:XCUIElementTypeButton identifier:@"ic visibility"].element typeText:@"test"];
  [tablesQuery.buttons[@"ic visibility"] tap];
  [tablesQuery.buttons[@"ic visibility off"] tap];
  [app.navigationBars[@"Create account"].buttons[@"SaveButtonAccessibilityID"] tap];
}

- (void)testSeveralIDPs {
  
  XCUIApplication *app = [[XCUIApplication alloc] init];
  XCUIElementQuery *tablesQuery = app.tables;
  [tablesQuery.cells.staticTexts[@"Google"] tap];
  [tablesQuery.cells.staticTexts[@"Simulate Existing User"] tap];
  [app.toolbars.buttons[@"Sign In"] tap];
  [app.buttons[@"EmailButtonAccessibilityID"] tap];
  [tablesQuery.cells[@"EmailCellAccessibilityID"].textFields[@"Enter your email"] tap];
  [[tablesQuery.cells[@"EmailCellAccessibilityID"] childrenMatchingType:XCUIElementTypeTextField].element typeText:@"test@test.com"];
  
  XCUIElement *signInWithEmailNavigationBar = app.navigationBars[@"Sign in with email"];
  [signInWithEmailNavigationBar.buttons[@"NextButtonAccessibilityID"] tap];
  [[[[app.navigationBars[@"Sign in"] childrenMatchingType:XCUIElementTypeButton] matchingIdentifier:@"Back"] elementBoundByIndex:0] tap];
  [[[[signInWithEmailNavigationBar childrenMatchingType:XCUIElementTypeButton] matchingIdentifier:@"Back"] elementBoundByIndex:0] tap];
  [app.navigationBars[@"Welcome"].buttons[@"Cancel"] tap];
  [app.alerts[@"Error"].buttons[@"Close"] tap];
}

- (void)testEmailRecovery {
  
  XCUIApplication *app = [[XCUIApplication alloc] init];
  XCUIElementQuery *tablesQuery = app.tables;
  [tablesQuery.cells.staticTexts[@"Simulate Email Recovery"] tap];
  [app.toolbars.buttons[@"Sign In"] tap];
  
  XCUIElement *enterYourEmailTextField = tablesQuery.cells[@"EmailCellAccessibilityID"].textFields[@"Enter your email"];
  [enterYourEmailTextField tap];
  [enterYourEmailTextField tap];
  [[tablesQuery.cells[@"EmailCellAccessibilityID"] childrenMatchingType:XCUIElementTypeTextField].element typeText:@"test@test.com"];

  XCUIElement *signInWithEmailNavigationBar = app.navigationBars[@"Sign in with email"];
  [signInWithEmailNavigationBar.buttons[@"NextButtonAccessibilityID"] tap];
  [tablesQuery.secureTextFields[@"Enter your password"] tap];
  [tablesQuery.buttons[@"Trouble signing in?"] tap];
  
  XCUIElement *recoverPasswordNavigationBar = app.navigationBars[@"Recover password"];
  [recoverPasswordNavigationBar.buttons[@"Send"] tap];
  XCUIElement *okButton = app.alerts.buttons[@"OK"];
  [okButton tap];
  [[[[recoverPasswordNavigationBar childrenMatchingType:XCUIElementTypeButton] matchingIdentifier:@"Back"] elementBoundByIndex:0] tap];
  [[[[app.navigationBars[@"Sign in"] childrenMatchingType:XCUIElementTypeButton] matchingIdentifier:@"Back"] elementBoundByIndex:0] tap];
  [signInWithEmailNavigationBar.buttons[@"Cancel"] tap];
  [app.alerts[@"Error"].buttons[@"Close"] tap];

}

- (void)testPhoneAuthCoutryPicker {
  XCUIApplication *app = [[XCUIApplication alloc] init];
  XCUIElementQuery *tablesQuery = app.tables;

  [tablesQuery.cells.staticTexts[@"Phone"] tap];
  [app.toolbars.buttons[@"Sign In"] tap];
  [app.buttons[@"Sign in with phone"] tap];

  [tablesQuery.staticTexts[@"Country"] tap];

  [app.tables.cells.staticTexts[@"\U0001F1E6\U0001F1F8 American Samoa"] tap];

  [tablesQuery.staticTexts[@"Country"] tap];
  [app.tables.searchFields[@"Search"] tap];
  [app.searchFields[@"Search"] typeText:@"united"];

  [app.tables.cells.staticTexts[@"\U0001F1FA\U0001F1F8 United States"]  forceTap];

  [app.navigationBars[@"Enter phone number"].buttons[@"Cancel"] tap];
  [app.navigationBars[@"Welcome"].buttons[@"Cancel"] tap];
  [app.alerts[@"Error"].buttons[@"Close"] tap];
}

- (void)testPhoneAuthFlow {
  XCUIApplication *app = [[XCUIApplication alloc] init];
  XCUIElementQuery *tablesQuery = app.tables;

  [tablesQuery.cells.staticTexts[@"Phone"] tap];
  [app.toolbars.buttons[@"Sign In"] tap];
  [app.buttons[@"Sign in with phone"] tap];

  [tablesQuery.cells[@"PhoneNumberCellAccessibilityID"].textFields[@"Phone number"] tap];
  [[tablesQuery.cells[@"PhoneNumberCellAccessibilityID"]
       childrenMatchingType:XCUIElementTypeTextField].element typeText:@"123456789"];
  [app.navigationBars[@"Enter phone number"].buttons[@"NextButtonAccessibilityID"] tap];

}

@end
