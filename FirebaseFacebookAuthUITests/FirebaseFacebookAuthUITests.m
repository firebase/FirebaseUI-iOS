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
#import "FUIFacebookAuthTest.h"
#import "FUIAuthUtils.h"
#import <FirebaseAuthUI/FirebaseAuthUI.h>
#import <FirebaseAuth/FirebaseAuth.h>
#import <FirebaseCore/FirebaseCore.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <OCMock/OCMock.h>

@interface FirebaseFacebookAuthUITests : XCTestCase
@property (nonatomic, strong) FUIFacebookAuthTest *provider;
@end

@implementation FirebaseFacebookAuthUITests

- (void)setUp {
  [super setUp];

  id mockUtilsClass = OCMClassMock([FUIAuthUtils class]);
  OCMStub(ClassMethod([mockUtilsClass bundleNamed:OCMOCK_ANY])).
      andReturn([NSBundle bundleForClass:[FUIFacebookAuthTest class]]);
  
  id authUIClass = OCMClassMock([FUIAuth class]);
  OCMStub(ClassMethod([authUIClass authUIWithAuth:OCMOCK_ANY])).
      andReturn(authUIClass);

  id authClass = OCMClassMock([FIRAuth class]);
  OCMStub(ClassMethod([authClass auth])).
      andReturn(authClass);

  self.provider = [[FUIFacebookAuthTest alloc] init];
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
}

- (void)testSuccessfullLogin {
  NSString *testToken = @"fakeToken";
  XCTAssertNotNil(self.provider);
  XCTAssertNil(self.provider.accessToken);

  FBSDKAccessToken *token = [[FBSDKAccessToken alloc] initWithTokenString:testToken
                                                              permissions:@[]
                                                      declinedPermissions:@[]
                                                                    appID:@"testAppId"
                                                                   userID:@"testUserId"
                                                           expirationDate:nil
                                                              refreshDate:nil];
  id mockToken = OCMPartialMock(token);

  FBSDKLoginManagerLoginResult *result = [[FBSDKLoginManagerLoginResult alloc] initWithToken:mockToken
                                                                                 isCancelled:NO
                                                                          grantedPermissions:nil
                                                                         declinedPermissions:nil];
  XCTAssertNil(_provider.accessToken);
  [self.provider configureLoginManager:result withError:nil];

  XCTestExpectation *expectation = [self expectationWithDescription:@"logged in"];
  [self.provider signInWithEmail:nil
        presentingViewController:nil
                      completion:^(FIRAuthCredential *_Nullable credential,
                                   NSError *_Nullable error,
                                   FIRAuthResultCallback _Nullable result) {
    XCTAssertNil(error);
    XCTAssertNotNil(credential);
    XCTAssertNotNil(result);
    FIRAuthCredential *expectedCredential = [FIRFacebookAuthProvider credentialWithAccessToken:testToken];
    XCTAssertEqualObjects(credential.provider, expectedCredential.provider);
    XCTAssertNil(self.provider.idToken);

    //verify that we are using token from server
    OCMVerify([mockToken tokenString]);

    [expectation fulfill];
  }];
  [self waitForExpectationsWithTimeout:0.1 handler:^(NSError *_Nullable error) {
    XCTAssertNil(error);
  }];
}

- (void)testCancelLogin {
  NSString *testToken = @"fakeToken";
  FBSDKAccessToken *token = [[FBSDKAccessToken alloc] initWithTokenString:testToken
                                                              permissions:@[]
                                                      declinedPermissions:@[]
                                                                    appID:@"testAppId"
                                                                   userID:@"testUserId"
                                                           expirationDate:nil
                                                              refreshDate:nil];
  id mockToken = OCMPartialMock(token);
  FBSDKLoginManagerLoginResult *result = [[FBSDKLoginManagerLoginResult alloc] initWithToken:mockToken
                                                                                 isCancelled:YES
                                                                          grantedPermissions:nil
                                                                         declinedPermissions:nil];
  [self.provider configureLoginManager:result withError:nil];

  XCTestExpectation *expectation = [self expectationWithDescription:@"logged in"];
  [self.provider signInWithEmail:nil
        presentingViewController:nil
                      completion:^(FIRAuthCredential *_Nullable credential,
                                   NSError *_Nullable error,
                                   FIRAuthResultCallback _Nullable result) {
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, FUIAuthErrorCodeUserCancelledSignIn);
    XCTAssertNil(credential);
    XCTAssertNil(result);
    XCTAssertNil(self.provider.idToken);

    //verify that we are not using token from server if user canceled request
    OCMReject([mockToken tokenString]);

    [expectation fulfill];
  }];
  [self waitForExpectationsWithTimeout:0.1 handler:^(NSError *_Nullable error) {
    XCTAssertNil(error);
  }];
}

- (void)testErrorLogin {
  NSError *testError = [NSError errorWithDomain:@"testErrorDomain" code:777 userInfo:nil];

  [self.provider configureLoginManager:nil withError:testError];

  XCTestExpectation *expectation = [self expectationWithDescription:@"logged in"];
  [self.provider signInWithEmail:nil
        presentingViewController:nil
                      completion:^(FIRAuthCredential *_Nullable credential,
                                   NSError *_Nullable error,
                                   FIRAuthResultCallback _Nullable result) {
    XCTAssertNotNil(error);
    XCTAssertEqual(error.userInfo[NSUnderlyingErrorKey], testError);
    XCTAssertNil(credential);
    XCTAssertNil(result);
    XCTAssertNil(self.provider.idToken);
    [expectation fulfill];
  }];
  [self waitForExpectationsWithTimeout:0.1 handler:^(NSError *_Nullable error) {
    XCTAssertNil(error);
  }];
}

- (void)testSignOut {
  id mockProvider = OCMPartialMock([[FUIFacebookAuth alloc] init]);
  id mockFacebookManager = OCMClassMock([FBSDKLoginManager class]);

  OCMExpect([mockProvider createLoginManager]).andReturn(mockFacebookManager);
  [mockProvider configureProvider];

  OCMExpect([mockFacebookManager logOut]);
  [mockProvider signOut];

  OCMVerifyAll(mockFacebookManager);
  OCMVerifyAll(mockProvider);

}

@end
