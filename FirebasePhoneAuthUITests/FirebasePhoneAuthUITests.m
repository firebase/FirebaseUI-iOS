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

#import "FUIAuthUtils.h"
#import <FirebasePhoneAuthUI/FirebasePhoneAuthUI.h>
#import <FirebaseAuth/FirebaseAuth.h>
#import <FirebaseCore/FirebaseCore.h>
#import <OCMock/OCMock.h>
#import "FUIAuthUtils.h"
#import "FUIPhoneAuth_Internal.h"

@interface FirebasePhoneAuthUITests : XCTestCase
@property (nonatomic, strong) FUIPhoneAuth *provider;
@end

@implementation FirebasePhoneAuthUITests

- (void)setUp {
  [super setUp];

  id mockUtilsClass = OCMClassMock([FUIAuthUtils class]);
  OCMStub(ClassMethod([mockUtilsClass bundleNamed:OCMOCK_ANY])).
      andReturn([NSBundle bundleForClass:[FUIPhoneAuth class]]);
  
  id authUIClass = OCMClassMock([FUIAuth class]);
  OCMStub(ClassMethod([authUIClass authUIWithAuth:OCMOCK_ANY])).
      andReturn(authUIClass);

  id authClass = OCMClassMock([FIRAuth class]);
  OCMStub(ClassMethod([authClass auth])).
      andReturn(authClass);

  self.provider = [[FUIPhoneAuth alloc] initWithAuthUI:[FUIAuth defaultAuthUI]];
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
  XCTAssertNotNil(self.provider.providerID);
  XCTAssertNotNil(self.provider.shortName);
  XCTAssertTrue(self.provider.signInLabel.length != 0);
  XCTAssertNil(self.provider.accessToken);
  XCTAssertNil(self.provider.idToken);
}

- (void)testSignIn {
  XCTAssertNotNil(self.provider);
  XCTAssertNil(self.provider.accessToken);

  id mockedProvider = OCMPartialMock(self.provider);

  XCTestExpectation *expectation = [self expectationWithDescription:@"logged in"];
  XCTestExpectation *expectationCallback = [self expectationWithDescription:@"result is called"];
  id mockedCredential = OCMClassMock([FIRAuthCredential class]);
  id mockedError = OCMClassMock([NSError class]);
  id mockedUser = OCMClassMock([FIRUser class]);
  FIRAuthResultCallback resultCallback = ^(FIRUser *_Nullable user, NSError *_Nullable error) {
    [expectationCallback fulfill];
    XCTAssertEqual(error, mockedError);
    XCTAssertEqual(user, mockedUser);
  };

  id mockedController = OCMClassMock([UIViewController class]);
  OCMExpect([mockedController presentViewController:OCMOCK_ANY
                                           animated:OCMOCK_ANY
                                         completion:OCMOCK_ANY]).andDo(^(NSInvocation *invocation) {
    [mockedProvider callbackWithCredential:mockedCredential
                                     error:mockedError
                                    result:resultCallback];
  });

  [mockedProvider signInWithEmail:nil
         presentingViewController:mockedController
                       completion:^(FIRAuthCredential *_Nullable credential,
                                    NSError *_Nullable error,
                                    FIRAuthResultCallback _Nullable result) {
    XCTAssertEqual(credential, mockedCredential);
    XCTAssertEqual(error, mockedError);
    [expectation fulfill];

    // We can't compare result and resultCallback. Thus verifying with expectation that result
    // is called.
    result(mockedUser, error);
  }];
  [self waitForExpectationsWithTimeout:0.1 handler:nil];

  OCMVerifyAll(mockedProvider);
}

@end
