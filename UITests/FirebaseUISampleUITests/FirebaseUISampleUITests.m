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
@property (nonatomic, strong) XCUIApplication *app;
@end

@implementation FirebaseUISampleUITests

- (void)setUp {
  [super setUp];
  self.continueAfterFailure = NO;
  self.app = [[XCUIApplication alloc] init];

  // force US locale on travis
  self.app.launchArguments = @[
    @"-inUITest",
    @"-AppleLanguages", @"(en)",
    @"-AppleLocale", @"en_US",
  ];

  [self.app launch];
}

- (void)tearDown {
  [self.app terminate];
  [super tearDown];
}

- (void)testSuccessSignIn {
  XCUIElementQuery *tablesQuery = self.app.tables;
  [tablesQuery.cells.staticTexts[@"Simulate Existing User"] tap];
  [self.app.toolbars.buttons[@"Sign In"] tap];
  [tablesQuery.cells[@"EmailCellAccessibilityID"].textFields[@"Enter your email"] tap];
  [[tablesQuery.cells[@"EmailCellAccessibilityID"] childrenMatchingType:XCUIElementTypeTextField].element typeText:@"test@test.com"];
  [self.app.navigationBars[@"Sign in with email"].buttons[@"NextButtonAccessibilityID"] tap];
  [tablesQuery.secureTextFields[@"Enter your password"] tap];
  [[[tablesQuery.cells containingType:XCUIElementTypeStaticText identifier:@"Password"] childrenMatchingType:XCUIElementTypeSecureTextField].element typeText:@"test"];
  [self.app.navigationBars[@"Sign in"].buttons[@"Sign in"] tap];
  [self.app.toolbars.buttons[@"Sign In"] isHittable];
}

- (void)testSuccessSignUp {
  XCUIElementQuery *tablesQuery = self.app.tables;
  [tablesQuery.staticTexts[@"Simulate New User"] tap];
  [self.app.toolbars.buttons[@"Sign In"] tap];
  
  [tablesQuery.cells[@"EmailCellAccessibilityID"].textFields[@"Enter your email"] tap];
  [[tablesQuery.cells[@"EmailCellAccessibilityID"] childrenMatchingType:XCUIElementTypeTextField].element typeText:@"test2@test2.com"];
  [self.app.navigationBars[@"Sign in with email"].buttons[@"NextButtonAccessibilityID"] tap];
  [tablesQuery.cells[@"NameSignUpCellAccessibilityID"].textFields[@"First & last name"] tap];
  [[tablesQuery.cells[@"NameSignUpCellAccessibilityID"] childrenMatchingType:XCUIElementTypeTextField].element typeText:@"test2"];
  
  [tablesQuery.cells[@"PasswordSignUpCellAccessibilityID"].secureTextFields[@"Choose password"] tap];
  [[tablesQuery.secureTextFields containingType:XCUIElementTypeButton identifier:@"ic visibility"].element typeText:@"test"];
  [tablesQuery.buttons[@"ic visibility"] tap];
  [tablesQuery.buttons[@"ic visibility off"] tap];
  [self.app.navigationBars[@"Create account"].buttons[@"SaveButtonAccessibilityID"] tap];
  [self.app.toolbars.buttons[@"Sign In"] isHittable];
}

- (void)testSeveralIDPs {
  XCUIElementQuery *tablesQuery = self.app.tables;
  [tablesQuery.cells.staticTexts[@"Google"] tap];
  [tablesQuery.cells.staticTexts[@"Simulate Existing User"] tap];
  [self.app.toolbars.buttons[@"Sign In"] tap];
  [self.app.buttons[@"EmailButtonAccessibilityID"] tap];
  [tablesQuery.cells[@"EmailCellAccessibilityID"].textFields[@"Enter your email"] tap];
  [[tablesQuery.cells[@"EmailCellAccessibilityID"] childrenMatchingType:XCUIElementTypeTextField].element typeText:@"test@test.com"];
  
  XCUIElement *signInWithEmailNavigationBar = self.app.navigationBars[@"Sign in with email"];
  [signInWithEmailNavigationBar.buttons[@"NextButtonAccessibilityID"] tap];
  [[[[self.app.navigationBars[@"Sign in"] childrenMatchingType:XCUIElementTypeButton] matchingIdentifier:@"Back"] elementBoundByIndex:0] tap];
  [[[[signInWithEmailNavigationBar childrenMatchingType:XCUIElementTypeButton] matchingIdentifier:@"Back"] elementBoundByIndex:0] tap];
  [self.app.navigationBars[@"Welcome"].buttons[@"Cancel"] tap];
  [self.app.alerts[@"Error"].buttons[@"Close"] tap];

  [self.app.toolbars.buttons[@"Sign In"] isHittable];
}

- (void)testEmailRecovery {
  XCUIElementQuery *tablesQuery = self.app.tables;
  [tablesQuery.cells.staticTexts[@"Simulate Email Recovery"] tap];
  [self.app.toolbars.buttons[@"Sign In"] tap];
  
  XCUIElement *enterYourEmailTextField = tablesQuery.cells[@"EmailCellAccessibilityID"].textFields[@"Enter your email"];
  [enterYourEmailTextField tap];
  [enterYourEmailTextField tap];
  [[tablesQuery.cells[@"EmailCellAccessibilityID"] childrenMatchingType:XCUIElementTypeTextField].element typeText:@"test@test.com"];

  XCUIElement *signInWithEmailNavigationBar = self.app.navigationBars[@"Sign in with email"];
  [signInWithEmailNavigationBar.buttons[@"NextButtonAccessibilityID"] tap];
  [tablesQuery.secureTextFields[@"Enter your password"] tap];
  [tablesQuery.buttons[@"Trouble signing in?"] tap];
  
  XCUIElement *recoverPasswordNavigationBar = self.app.navigationBars[@"Recover password"];
  [recoverPasswordNavigationBar.buttons[@"Send"] tap];
  XCUIElement *okButton = self.app.alerts.buttons[@"OK"];
  [okButton tap];
  [[[[recoverPasswordNavigationBar childrenMatchingType:XCUIElementTypeButton] matchingIdentifier:@"Back"] elementBoundByIndex:0] tap];
  [[[[self.app.navigationBars[@"Sign in"] childrenMatchingType:XCUIElementTypeButton] matchingIdentifier:@"Back"] elementBoundByIndex:0] tap];
  [signInWithEmailNavigationBar.buttons[@"Cancel"] tap];
  [self.app.alerts[@"Error"].buttons[@"Close"] tap];

  [self.app.toolbars.buttons[@"Sign In"] isHittable];
}

- (void)testPhoneAuthCountryPicker {
  XCUIElementQuery *tablesQuery = self.app.tables;

  [tablesQuery.cells.staticTexts[@"Phone"] tap];
  [self.app.toolbars.buttons[@"Sign In"] tap];
  [self.app.buttons[@"Sign in with phone"] tap];

  [tablesQuery.staticTexts[@"Country"] tap];

  [self.app.tables.cells.staticTexts[@"\U0001F1E6\U0001F1F8 American Samoa"] tap];

  [tablesQuery.staticTexts[@"Country"] tap];
  [self.app.tables.searchFields[@"Search"] tap];
  [self.app.searchFields[@"Search"] typeText:@"united"];

  [self.app.tables.cells.staticTexts[@"\U0001F1FA\U0001F1F8 United States"] forceTap];

  [self.app.navigationBars[@"Enter phone number"].buttons[@"Cancel"] tap];
  [self.app.navigationBars[@"Welcome"].buttons[@"Cancel"] tap];
  [self.app.alerts[@"Error"].buttons[@"Close"] tap];

  [self.app.toolbars.buttons[@"Sign In"] isHittable];
}

- (void)testPhoneAuthFlow {
  XCUIElementQuery *tablesQuery = self.app.tables;

  [tablesQuery.cells.staticTexts[@"Phone"] tap];
  [self.app.toolbars.buttons[@"Sign In"] tap];
  [self.app.buttons[@"Sign in with phone"] tap];

  [tablesQuery.cells[@"PhoneNumberCellAccessibilityID"].textFields[@"Phone number"] tap];
  [[tablesQuery.cells[@"PhoneNumberCellAccessibilityID"]
       childrenMatchingType:XCUIElementTypeTextField].element typeText:@"123456789"];
  [self.app.navigationBars[@"Enter phone number"].buttons[@"NextButtonAccessibilityID"] tap];

  [self.app.keyboards.keys[@"1"] tap];
  [self.app.keyboards.keys[@"2"] tap];
  [self.app.keyboards.keys[@"3"] tap];
  [self.app.keyboards.keys[@"4"] tap];
  [self.app.keyboards.keys[@"5"] tap];
  
  XCUIElement *nextbuttonaccessibilityidButton =
      self.app.navigationBars[@"Verify phone number"].buttons[@"NextButtonAccessibilityID"];
  [nextbuttonaccessibilityidButton tap];
  [self.app.keyboards.keys[@"6"] tap];
  [nextbuttonaccessibilityidButton tap];

  [self.app.toolbars.buttons[@"Sign In"] isHittable];
}

- (void)testDirectPhoneAuthSignIn {
  XCUIElementQuery *tablesQuery = self.app.tables;
  [tablesQuery.cells.staticTexts[@"Phone"] tap];
  [tablesQuery.cells.staticTexts[@"Email"] tap];
  
  XCUIElement *signInButton = self.app.toolbars.buttons[@"Sign In"];
  [signInButton tap];

  XCUIElement *textField = [tablesQuery.cells[@"PhoneNumberCellAccessibilityID"]
                               childrenMatchingType:XCUIElementTypeTextField].element;
  [textField typeText:@"1"];

  XCUIElement *enterPhoneNumberNavigationBar = self.app.navigationBars[@"Enter phone number"];
  XCUIElement *nextbuttonaccessibilityidButton =
      enterPhoneNumberNavigationBar.buttons[@"NextButtonAccessibilityID"];
  [nextbuttonaccessibilityidButton tap];
  [self.app.buttons[@"+11"] tap];
  [enterPhoneNumberNavigationBar.buttons[@"Cancel"] tap];
  [self.app.alerts[@"Error"].buttons[@"Close"] tap];
  [signInButton tap];
  [textField typeText:@"2"];
  [nextbuttonaccessibilityidButton tap];
  [self.app.keyboards.keys[@"1"] tap];
  [self.app.keyboards.keys[@"2"] tap];
  [self.app.keyboards.keys[@"3"] tap];
  [self.app.keyboards.keys[@"4"] tap];
  [self.app.keyboards.keys[@"5"] tap];
  [self.app.keyboards.keys[@"6"] tap];
  [self.app.navigationBars[@"Verify phone number"].buttons[@"NextButtonAccessibilityID"] tap];

  [self.app.toolbars.buttons[@"Sign In"] isHittable];
}

@end
