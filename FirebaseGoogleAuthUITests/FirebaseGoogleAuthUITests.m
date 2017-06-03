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

#import <FirebaseAuth/FirebaseAuth.h>
#import <FirebaseAuthUI/FUIAuthErrorUtils.h>
#import <FirebaseAuthUI/FUIAuthUtils.h>
#import <FirebaseCore/FirebaseCore.h>
#import <FirebaseGoogleAuthUI/FirebaseGoogleAuthUI.h>
#import <GoogleSignIn/GoogleSignIn.h>
#import <OCMock/OCMock.h>
@import XCTest;

@interface FUIGoogleAuth (Testing)
- (GIDSignIn *)configuredGoogleSignIn;
@end

@interface FirebaseGoogleAuthUITests : XCTestCase
@property (nonatomic, strong) id mockProvider;

@end

@implementation FirebaseGoogleAuthUITests

- (void)setUp {
  [super setUp];
  self.mockProvider =  OCMPartialMock([[FUIGoogleAuth alloc] init]);

  id mockUtilsClass = OCMClassMock([FUIAuthUtils class]);
  OCMStub(ClassMethod([mockUtilsClass bundleNamed:OCMOCK_ANY])).
      andReturn([NSBundle bundleForClass:[FUIGoogleAuth class]]);
  
  id authUIClass = OCMClassMock([FUIAuth class]);
  OCMStub(ClassMethod([authUIClass authUIWithAuth:OCMOCK_ANY])).
      andReturn(authUIClass);

  id authClass = OCMClassMock([FIRAuth class]);
  OCMStub(ClassMethod([authClass auth])).
      andReturn(authClass);
}

- (void)tearDown {
  self.mockProvider = nil;
  [super tearDown];
}

- (void)testProviderValidity {
  FUIGoogleAuth *provider = [[FUIGoogleAuth alloc] init];

  XCTAssertNotNil(provider);
  XCTAssertNotNil(provider.icon);
  XCTAssertNotNil(provider.signInLabel);
  XCTAssertNotNil(provider.buttonBackgroundColor);
  XCTAssertNotNil(provider.buttonTextColor);
  XCTAssertNotNil(provider.providerID);
  XCTAssertNotNil(provider.shortName);
  XCTAssertTrue(provider.signInLabel.length != 0);
  XCTAssertNil(provider.accessToken);
  XCTAssertNil(provider.idToken);
}

- (void)testSuccessfullLogin {
  NSString *testIdToken = @"idToken";
  NSString *testAccessToken = @"accessToken";

  id mockSignInDelegate = _mockProvider;
  id mockSignIn = OCMClassMock([GIDSignIn class]);
  id mockAuthentication = OCMClassMock([GIDAuthentication class]);
  id mockGoogleUser = OCMClassMock([GIDGoogleUser class]);

  // mock accessToken
  OCMExpect([mockGoogleUser authentication]).andReturn(mockAuthentication);
  OCMExpect([mockAuthentication accessToken]).andReturn(testAccessToken);

  // mock idToken
  OCMExpect([mockGoogleUser authentication]).andReturn(mockAuthentication);
  OCMExpect([mockAuthentication idToken]).andReturn(testIdToken);

  OCMExpect([_mockProvider configuredGoogleSignIn]).andReturn(mockSignIn);

  //forward call to signIn delegate
  OCMExpect([mockSignIn signIn]).andDo(^(NSInvocation *invocation) {
    [mockSignInDelegate signIn:mockSignIn didSignInForUser:mockGoogleUser withError:nil];
  });

  XCTestExpectation *expectation = [self expectationWithDescription:@"logged in"];

  [_mockProvider signInWithEmail:nil
        presentingViewController:nil
                      completion:^(FIRAuthCredential *_Nullable credential,
                                   NSError *_Nullable error,
                                   FIRAuthResultCallback _Nullable result) {
    XCTAssertNil(error);
    XCTAssertNotNil(result);
    XCTAssertNotNil(credential);
    FIRAuthCredential *expectedCredential =
        [FIRGoogleAuthProvider credentialWithIDToken:testIdToken accessToken:testAccessToken];
    XCTAssertEqualObjects(credential.provider, expectedCredential.provider);

    [expectation fulfill];
    // We can't compare result and resultCallback. Thus verifying with expectation that result
    // is called.
    result(mockGoogleUser, error);
  }];
  [self waitForExpectationsWithTimeout:0.1 handler:^(NSError *_Nullable error) {
    XCTAssertNil(error);
  }];
  
  OCMVerifyAll(_mockProvider);
  OCMVerifyAll(mockSignInDelegate);
  OCMVerifyAll(mockGoogleUser);

  //verify that we are doing actual sign in
  OCMVerifyAll(mockSignIn);
  //verify that we are using token from server
  OCMVerifyAll(mockAuthentication);
}

- (void)testErrorLogin {
  NSString *testIdToken = @"idToken";
  NSString *testAccessToken = @"accessToken";

  id mockSignInDelegate = _mockProvider;
  id mockSignIn = OCMClassMock([GIDSignIn class]);
  id mockAuthentication = OCMClassMock([GIDAuthentication class]);
  id mockGoogleUser = OCMClassMock([GIDGoogleUser class]);

  // mock accessToken
  OCMReject([mockGoogleUser authentication]).andReturn(mockAuthentication);
  OCMReject([mockAuthentication accessToken]).andReturn(testAccessToken);

  // mock idToken
  OCMReject([mockGoogleUser authentication]).andReturn(mockAuthentication);
  OCMReject([mockAuthentication idToken]).andReturn(testIdToken);

  OCMExpect([_mockProvider configuredGoogleSignIn]).andReturn(mockSignIn);
  NSError *signInError = [NSError errorWithDomain:@"sign in domain" code:kGIDSignInErrorCodeUnknown userInfo:@{}];

  OCMExpect([mockSignIn signIn]).andDo(^(NSInvocation *invocation) {
    [mockSignInDelegate signIn:mockSignIn didSignInForUser:mockGoogleUser withError:signInError];
  });


  XCTestExpectation *expectation = [self expectationWithDescription:@"logged in"];

  [_mockProvider signInWithEmail:nil
        presentingViewController:nil
                      completion:^(FIRAuthCredential *_Nullable credential,
                                   NSError *_Nullable error,
                                   FIRAuthResultCallback _Nullable result) {
    XCTAssertNotNil(error);
    XCTAssertEqualObjects(error.userInfo[NSUnderlyingErrorKey], signInError);
    XCTAssertNil(credential);
    XCTAssertNil(result);
    [expectation fulfill];
  }];
  [self waitForExpectationsWithTimeout:0.1 handler:^(NSError *_Nullable error) {
    XCTAssertNil(error);
  }];

  OCMVerifyAll(_mockProvider);
  OCMVerifyAll(mockSignInDelegate);
  OCMVerifyAll(mockGoogleUser);

  //verify that we are doing actual sign in
  OCMVerifyAll(mockSignIn);
  //verify that we are using token from server
  OCMVerifyAll(mockAuthentication);
}

- (void)testCancelLogin {
  NSString *testIdToken = @"idToken";
  NSString *testAccessToken = @"accessToken";

  id mockSignInDelegate = _mockProvider;
  id mockSignIn = OCMClassMock([GIDSignIn class]);
  id mockAuthentication = OCMClassMock([GIDAuthentication class]);
  id mockGoogleUser = OCMClassMock([GIDGoogleUser class]);

  // mock accessToken
  OCMReject([mockGoogleUser authentication]).andReturn(mockAuthentication);
  OCMReject([mockAuthentication accessToken]).andReturn(testAccessToken);

  // mock idToken
  OCMReject([mockGoogleUser authentication]).andReturn(mockAuthentication);
  OCMReject([mockAuthentication idToken]).andReturn(testIdToken);

  OCMExpect([_mockProvider configuredGoogleSignIn]).andReturn(mockSignIn);
  NSError *signInError = [NSError errorWithDomain:@"sign in domain" code:kGIDSignInErrorCodeCanceled userInfo:@{}];

  OCMExpect([mockSignIn signIn]).andDo(^(NSInvocation *invocation) {
    [mockSignInDelegate signIn:mockSignIn didSignInForUser:mockGoogleUser withError:signInError];
  });

  XCTestExpectation *expectation = [self expectationWithDescription:@"logged in"];

  [_mockProvider signInWithEmail:nil
        presentingViewController:nil
                      completion:^(FIRAuthCredential *_Nullable credential,
                                   NSError *_Nullable error,
                                   FIRAuthResultCallback _Nullable result) {
    XCTAssertNotNil(error);
    XCTAssertEqualObjects(error, [FUIAuthErrorUtils userCancelledSignInError]);
    XCTAssertNil(credential);
    XCTAssertNil(result);

    [expectation fulfill];
  }];
  [self waitForExpectationsWithTimeout:0.1 handler:^(NSError *_Nullable error) {
    XCTAssertNil(error);
  }];

  OCMVerifyAll(_mockProvider);
  OCMVerifyAll(mockSignInDelegate);
  OCMVerifyAll(mockGoogleUser);

  //verify that we are doing actual sign in
  OCMVerifyAll(mockSignIn);
  //verify that we are using token from server
  OCMVerifyAll(mockAuthentication);
}

- (void)testSignOut {
  id mockSignIn = OCMClassMock([GIDSignIn class]);
  OCMExpect([_mockProvider configuredGoogleSignIn]).andReturn(mockSignIn);
  OCMExpect([mockSignIn signOut]);

  [_mockProvider signOut];

  OCMVerifyAll(_mockProvider);
  OCMVerifyAll(mockSignIn);
}


@end
