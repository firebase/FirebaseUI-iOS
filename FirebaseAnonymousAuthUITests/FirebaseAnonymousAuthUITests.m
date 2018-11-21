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

#import "FUIAnonymousAuth.h"
#import <FirebaseAuth/FirebaseAuth.h>
#import <FirebaseAuthUI/FUIAuthErrorUtils.h>
#import "FUIAuthUtils.h"
#import <FirebaseAuthUI/FUIAuth.h>
#import <FirebaseAnonymousAuthUI/FirebaseAnonymousAuthUI.h>
#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>

@interface FirebaseAnonymousAuthUITests : XCTestCase
@property (nonatomic, strong) FUIAnonymousAuth *provider;
@end

@implementation FirebaseAnonymousAuthUITests

- (void)setUp {
  [super setUp];

  id mockUtilsClass = OCMClassMock([FUIAuthUtils class]);
  OCMStub(ClassMethod([mockUtilsClass bundleNamed:OCMOCK_ANY])).
      andReturn([NSBundle bundleForClass:[FUIAnonymousAuth class]]);
  
  id authUIClass = OCMClassMock([FUIAuth class]);
  OCMStub(ClassMethod([authUIClass authUIWithAuth:OCMOCK_ANY])).
      andReturn(authUIClass);

  id authClass = OCMClassMock([FIRAuth class]);
  OCMStub(ClassMethod([authClass auth])).
      andReturn(authClass);

  FIRAuth *auth = [FIRAuth auth];
  FUIAuth *authUI = [FUIAuth authUIWithAuth:auth];
  self.provider = [[FUIAnonymousAuth alloc] initWithAuthUI:authUI];
}

- (void)tearDown {
  self.provider = nil;
  [super tearDown];
}

- (void)testProviderValidity {
  XCTAssertNotNil(self.provider);
  XCTAssertNotNil(self.provider.icon);
  XCTAssertNotNil(self.provider.signInLabel);
  XCTAssertNotNil(self.provider.buttonBackgroundColor);
  XCTAssertNotNil(self.provider.buttonTextColor);
  XCTAssertNil(self.provider.providerID);
  XCTAssertNotNil(self.provider.shortName);
  XCTAssertTrue(self.provider.signInLabel.length != 0);
  XCTAssertNil(self.provider.accessToken);
  XCTAssertNil(self.provider.idToken);
}

@end
