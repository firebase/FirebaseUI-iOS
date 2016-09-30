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
#import <OCMock/OCMock.h>
#import <FirebaseTwitterAuthUI/FirebaseTwitterAuthUI.h>

#import <FirebaseAuthUI/FIRAuthUIErrorUtils.h>
#import <TwitterKit/TwitterKit.h>
#import <TwitterCore/TwitterCore.h>
#import <FirebaseAuth/FirebaseAuth.h>
#import "FIRTwitterAuthUI.h"

@interface FIRTwitterAuthUI (Testing)
- (Twitter *)getTwitterManager;
@end

@interface FirebaseTwitterAuthUITests : XCTestCase
@property (nonatomic, strong) FIRTwitterAuthUI *provider;
@end

@implementation FirebaseTwitterAuthUITests

- (void)setUp {
  [super setUp];
  self.provider = [[FIRTwitterAuthUI alloc] init];
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
}


- (void)testSuccessfullLogin {
  XCTAssertNotNil(self.provider);
  XCTAssertNil(self.provider.accessToken);

  id mockerProvider = OCMPartialMock(self.provider);
  id mockedTwitterManager = OCMPartialMock([Twitter sharedInstance]);

  NSString *testToken = @"authToken";
  NSString *testSecret = @"secret";
  TWTRSession *session = [[TWTRSession alloc] initWithAuthToken:testToken
                                               authTokenSecret:testSecret
                                                      userName:@"tsetUser"
                                                        userID:@"userID"];

  OCMStub([mockerProvider getTwitterManager]).andReturn(mockedTwitterManager);
  OCMStub([mockedTwitterManager logInWithCompletion:([OCMArg invokeBlockWithArgs:session, [NSNull null], nil])]);


  XCTestExpectation *expectation = [self expectationWithDescription:@"logged in"];
  [mockerProvider signInWithEmail:nil
        presentingViewController:nil
                      completion:^(FIRAuthCredential * _Nullable credential, NSError * _Nullable error) {
                        XCTAssertNil(error);
                        XCTAssertNotNil(credential);
                        FIRAuthCredential *expectedCredential = [FIRTwitterAuthProvider credentialWithToken:testToken secret:testSecret];
                        XCTAssertEqualObjects(credential.provider, expectedCredential.provider);
                        //TODO: test access token validity
                        [expectation fulfill];
                      }];
  [self waitForExpectationsWithTimeout:0.1 handler:^(NSError * _Nullable error) {
    XCTAssertNil(error);
  }];

  OCMVerify([mockerProvider getTwitterManager]);
}

- (void)testErrorLogin {
  XCTAssertNotNil(self.provider);
  XCTAssertNil(self.provider.accessToken);

  id mockerProvider = OCMPartialMock(self.provider);
  id mockedTwitterManager = OCMPartialMock([Twitter sharedInstance]);

  NSError *loginError = [NSError errorWithDomain:@"errorDomain" code:777 userInfo:nil];

  OCMStub([mockerProvider getTwitterManager]).andReturn(mockedTwitterManager);
  OCMStub([mockedTwitterManager logInWithCompletion:([OCMArg invokeBlockWithArgs:[NSNull null], loginError, nil])]);


  XCTestExpectation *expectation = [self expectationWithDescription:@"logged in"];
  [mockerProvider signInWithEmail:nil
         presentingViewController:nil
                       completion:^(FIRAuthCredential * _Nullable credential, NSError * _Nullable error) {
                         XCTAssertNil(credential);
                         XCTAssertNotNil(error);
                         XCTAssertEqualObjects(error.userInfo[NSUnderlyingErrorKey], loginError);
                         //TODO: test access token validity
                         [expectation fulfill];
                       }];
  [self waitForExpectationsWithTimeout:0.1 handler:^(NSError * _Nullable error) {
    XCTAssertNil(error);
  }];

  OCMVerify([mockerProvider getTwitterManager]);
}

- (void)testSignOut {
  id mockerProvider = OCMPartialMock(self.provider);
  id mockedTwitterManager = OCMPartialMock([Twitter sharedInstance]);

  id mockedSessionStore = OCMClassMock([TWTRSessionStore class]);
  id mockedTwitterClient = OCMClassMock([TWTRAPIClient class]);

  NSString *testClientId = @"testClientId";
  OCMStub([mockedTwitterClient userID]).andReturn(testClientId);
  OCMStub(ClassMethod([mockedTwitterClient clientWithCurrentUser])).andReturn(mockedTwitterClient);

  OCMStub([mockerProvider getTwitterManager]).andReturn(mockedTwitterManager);
  OCMStub([mockedTwitterManager sessionStore]).andReturn(mockedSessionStore);

  [mockerProvider signOut];
  //verify we are calling sign out method
  OCMVerify([mockedSessionStore logOutUserID:testClientId]);
}


@end
