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
#import <FirebaseUI/FUIAuthErrorUtils.h>
#import <FirebaseUI/FUIAuthUtils.h>
#import <FirebaseUI/FUIAuth.h>
#import <GoogleSignIn/GoogleSignIn.h>
#import <OCMock/OCMock.h>
@import XCTest;

#import "FUIGoogleAuth.h"

@interface FUIGoogleAuth (Testing)
- (GIDSignIn *)configuredGoogleSignIn;
@end

@interface FirebaseGoogleAuthUITests : XCTestCase
@property (nonatomic, strong) id mockProvider;
@property (nonatomic, strong) id mockOAuthProvider;
@property (nonatomic, strong) FUIAuth *authUI;
@end

@implementation FirebaseGoogleAuthUITests

- (void)setUp {
  [super setUp];
  id mockUtilsClass = OCMClassMock([FUIAuthUtils class]);
  OCMStub(ClassMethod([mockUtilsClass bundleNamed:OCMOCK_ANY])).
      andReturn([NSBundle bundleForClass:[FUIGoogleAuth class]]);

  id authClass = OCMClassMock([FIRAuth class]);
  OCMStub(ClassMethod([authClass auth])).
      andReturn(authClass);

  self.mockOAuthProvider = OCMClassMock([FIROAuthProvider class]);
  OCMStub(ClassMethod([_mockOAuthProvider providerWithProviderID:OCMOCK_ANY])).
      andReturn(_mockOAuthProvider);

  FIRAuth *auth = [FIRAuth auth];
  self.authUI = [FUIAuth authUIWithAuth:auth];
  self.mockProvider =  OCMPartialMock([[FUIGoogleAuth alloc] initWithAuthUI:self.authUI]);
}

- (void)tearDown {
  self.mockProvider = nil;
  self.mockOAuthProvider = nil;
  self.authUI = nil;
  [super tearDown];
}

- (void)testProviderValidity {
  FUIGoogleAuth *provider = [[FUIGoogleAuth alloc] initWithAuthUI:self.authUI];

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

  OCMVerify(never(), [self.mockOAuthProvider providerWithProviderID:@"google.com"]);
}

- (void)testUseEmulatorCreatesOAuthProvider {
  [self.authUI useEmulatorWithHost:@"host" port:12345];
  FUIGoogleAuth *provider = [[FUIGoogleAuth alloc] initWithAuthUI:self.authUI];

  XCTAssertNotNil(provider);
  OCMVerify([self.mockOAuthProvider providerWithProviderID:@"google.com"]);
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

  [_mockProvider signInWithDefaultValue:nil
               presentingViewController:nil
                             completion:^(FIRAuthCredential *_Nullable credential,
                                          NSError *_Nullable error,
                                          FIRAuthResultCallback _Nullable result,
                                          NSDictionary *_Nullable userInfo) {
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
  OCMVerify(never(), [self.mockOAuthProvider getCredentialWithUIDelegate:nil completion:OCMOCK_ANY]);
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (void)testLegacyInitSuccessfulLogin {
  NSString *testIdToken = @"idToken";
  NSString *testAccessToken = @"accessToken";

  _mockProvider =  OCMPartialMock([[FUIGoogleAuth alloc] init]);

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

  [_mockProvider signInWithDefaultValue:nil
               presentingViewController:nil
                             completion:^(FIRAuthCredential *_Nullable credential,
                                          NSError *_Nullable error,
                                          FIRAuthResultCallback _Nullable result,
                                          NSDictionary *_Nullable userInfo) {
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
  OCMVerify(never(), [self.mockOAuthProvider getCredentialWithUIDelegate:nil completion:OCMOCK_ANY]);
}
#pragma clang diagnostic pop

- (void)testErrorLogin {
  NSString *testIdToken = @"idToken";
  NSString *testAccessToken = @"accessToken";

  id mockSignInDelegate = _mockProvider;
  id mockSignIn = OCMClassMock([GIDSignIn class]);
  id mockAuthentication = OCMClassMock([GIDAuthentication class]);
  id mockGoogleUser = OCMClassMock([GIDGoogleUser class]);

  // mock accessToken
  OCMStub([mockGoogleUser authentication]).andReturn(mockAuthentication);
  OCMStub([mockAuthentication accessToken]).andReturn(testAccessToken);

  // mock idToken
  OCMStub([mockGoogleUser authentication]).andReturn(mockAuthentication);
  OCMStub([mockAuthentication idToken]).andReturn(testIdToken);

  OCMExpect([_mockProvider configuredGoogleSignIn]).andReturn(mockSignIn);
  NSError *signInError = [NSError errorWithDomain:@"sign in domain" code:kGIDSignInErrorCodeUnknown userInfo:@{}];

  OCMExpect([mockSignIn signIn]).andDo(^(NSInvocation *invocation) {
    [mockSignInDelegate signIn:mockSignIn didSignInForUser:mockGoogleUser withError:signInError];
  });


  XCTestExpectation *expectation = [self expectationWithDescription:@"logged in"];

  [_mockProvider signInWithDefaultValue:nil
               presentingViewController:nil
                             completion:^(FIRAuthCredential *_Nullable credential,
                                          NSError *_Nullable error,
                                          FIRAuthResultCallback _Nullable result,
                                          NSDictionary *_Nullable userInfo) {
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
  OCMStub([mockGoogleUser authentication]).andReturn(mockAuthentication);
  OCMStub([mockAuthentication accessToken]).andReturn(testAccessToken);

  // mock idToken
  OCMStub([mockGoogleUser authentication]).andReturn(mockAuthentication);
  OCMStub([mockAuthentication idToken]).andReturn(testIdToken);

  OCMExpect([_mockProvider configuredGoogleSignIn]).andReturn(mockSignIn);
  NSError *signInError = [NSError errorWithDomain:@"sign in domain" code:kGIDSignInErrorCodeCanceled userInfo:@{}];

  OCMExpect([mockSignIn signIn]).andDo(^(NSInvocation *invocation) {
    [mockSignInDelegate signIn:mockSignIn didSignInForUser:mockGoogleUser withError:signInError];
  });

  XCTestExpectation *expectation = [self expectationWithDescription:@"logged in"];

  [_mockProvider signInWithDefaultValue:nil
               presentingViewController:nil
                             completion:^(FIRAuthCredential *_Nullable credential,
                                          NSError *_Nullable error,
                                          FIRAuthResultCallback _Nullable result,
                                          NSDictionary *_Nullable userInfo) {
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

- (void)testUseEmulatorUsesOAuthProvider {
  [self.authUI useEmulatorWithHost:@"host" port:12345];
  self.mockProvider =  OCMPartialMock([[FUIGoogleAuth alloc] initWithAuthUI:self.authUI]);

  [self.mockProvider signInWithDefaultValue:nil
               presentingViewController:nil
                             completion:^(FIRAuthCredential *_Nullable credential,
                                          NSError *_Nullable error,
                                          FIRAuthResultCallback _Nullable result,
                                          NSDictionary *_Nullable userInfo) {}];

  OCMVerify([self.mockOAuthProvider getCredentialWithUIDelegate:nil completion:OCMOCK_ANY]);
  OCMVerify(never(), [self.mockProvider configuredGoogleSignIn]);
}


@end
