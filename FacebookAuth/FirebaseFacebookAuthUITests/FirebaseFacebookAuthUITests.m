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

#import "FUIFacebookAuth.h"
#import "FUIFacebookAuthTest.h"

#import "FUIAuthUtils.h"
#import <FirebaseUI/FirebaseAuthUI.h>
#import <FirebaseAuth/FirebaseAuth.h>
#import <FirebaseCore/FirebaseCore.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <OCMock/OCMock.h>

@interface FirebaseFacebookAuthUITests : XCTestCase
@property (nonatomic, strong) FUIFacebookAuthTest *provider;
@property (nonatomic, strong) FUIAuth *authUI;
@property (nonatomic, strong) id mockOAuthProvider;
@end

@implementation FirebaseFacebookAuthUITests

- (void)setUp {
  [super setUp];

  id mockUtilsClass = OCMClassMock([FUIAuthUtils class]);
  OCMStub(ClassMethod([mockUtilsClass bundleNamed:OCMOCK_ANY])).
      andReturn([NSBundle bundleForClass:[FUIFacebookAuthTest class]]);

  id authClass = OCMClassMock([FIRAuth class]);
  OCMStub(ClassMethod([authClass auth])).
      andReturn(authClass);

  self.mockOAuthProvider = OCMClassMock([FIROAuthProvider class]);
  OCMStub(ClassMethod([self.mockOAuthProvider providerWithProviderID:OCMOCK_ANY])).
      andReturn(self.mockOAuthProvider);

  FIRAuth *auth = [FIRAuth auth];
  self.authUI = [FUIAuth authUIWithAuth:auth];
  self.provider = [[FUIFacebookAuthTest alloc] initWithAuthUI:self.authUI];
}

- (void)tearDown {
  self.provider = nil;
  self.authUI = nil;
  self.mockOAuthProvider = nil;
  [super tearDown];
}

- (void)testProviderValidity {
  self.provider = [[FUIFacebookAuthTest alloc] initWithAuthUI:self.authUI];

  XCTAssertNotNil(self.provider);
  XCTAssertNotNil(self.provider.icon);
  XCTAssertNotNil(self.provider.signInLabel);
  XCTAssertNotNil(self.provider.buttonBackgroundColor);
  XCTAssertNotNil(self.provider.buttonTextColor);
  XCTAssertNotNil(self.provider.providerID);
  XCTAssertNotNil(self.provider.shortName);
  XCTAssertTrue(self.provider.signInLabel.length != 0);

  OCMVerify(never(), [self.mockOAuthProvider providerWithProviderID:@"facebook.com"]);
}

- (void)testUseEmulatorCreatesOAuthProvider {
  [self.authUI useEmulatorWithHost:@"host" port:12345];
  self.provider = [[FUIFacebookAuthTest alloc] initWithAuthUI:self.authUI];

  XCTAssertNotNil(self.provider);
  OCMVerify([self.mockOAuthProvider providerWithProviderID:@"facebook.com"]);
}

- (void)testSuccessfullLogin {
  NSString *testToken = @"fakeToken";
  XCTAssertNotNil(self.provider);
  XCTAssertNil(self.provider.accessToken);

  FBSDKAccessToken *token = [[FBSDKAccessToken alloc] initWithTokenString:testToken
                                                              permissions:@[]
                                                      declinedPermissions:@[]
                                                       expiredPermissions:@[]
                                                                    appID:@"testAppId"
                                                                   userID:@"testUserId"
                                                           expirationDate:nil
                                                              refreshDate:nil
                                                 dataAccessExpirationDate:nil];
  id mockToken = OCMPartialMock(token);

  NSSet *emptySet = [NSSet set];
  FBSDKLoginManagerLoginResult *result = [[FBSDKLoginManagerLoginResult alloc] initWithToken:mockToken
                                                                                 isCancelled:NO
                                                                          grantedPermissions:emptySet
                                                                         declinedPermissions:emptySet];
  XCTAssertNil(_provider.accessToken);
  [self.provider configureLoginManager:result withError:nil];

  XCTestExpectation *expectation = [self expectationWithDescription:@"logged in"];
  [self.provider signInWithDefaultValue:nil
               presentingViewController:nil
                             completion:^(FIRAuthCredential *_Nullable credential,
                                          NSError *_Nullable error,
                                          FIRAuthResultCallback _Nullable result,
                                          NSDictionary *_Nullable userInfo) {
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

  OCMVerify(never(), [self.mockOAuthProvider getCredentialWithUIDelegate:nil completion:OCMOCK_ANY]);
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (void)testLegacyInitSuccessfulLogin {
  self.provider = [[FUIFacebookAuthTest alloc] init];

  NSString *testToken = @"fakeToken";
  XCTAssertNotNil(self.provider);
  XCTAssertNil(self.provider.accessToken);

  FBSDKAccessToken *token = [[FBSDKAccessToken alloc] initWithTokenString:testToken
                                                              permissions:@[]
                                                      declinedPermissions:@[]
                                                       expiredPermissions:@[]
                                                                    appID:@"testAppId"
                                                                   userID:@"testUserId"
                                                           expirationDate:nil
                                                              refreshDate:nil
                                                 dataAccessExpirationDate:nil];
  id mockToken = OCMPartialMock(token);

  NSSet *emptySet = [NSSet set];
  FBSDKLoginManagerLoginResult *result = [[FBSDKLoginManagerLoginResult alloc] initWithToken:mockToken
                                                                                 isCancelled:NO
                                                                          grantedPermissions:emptySet
                                                                         declinedPermissions:emptySet];
  XCTAssertNil(_provider.accessToken);
  [self.provider configureLoginManager:result withError:nil];

  XCTestExpectation *expectation = [self expectationWithDescription:@"logged in"];
  [self.provider signInWithDefaultValue:nil
               presentingViewController:nil
                             completion:^(FIRAuthCredential *_Nullable credential,
                                          NSError *_Nullable error,
                                          FIRAuthResultCallback _Nullable result,
                                          NSDictionary *_Nullable userInfo) {
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

  OCMVerify(never(), [self.mockOAuthProvider getCredentialWithUIDelegate:nil completion:OCMOCK_ANY]);
}
#pragma clang diagnostic pop

- (void)testCancelLogin {
  NSString *testToken = @"fakeToken";
  FBSDKAccessToken *token = [[FBSDKAccessToken alloc] initWithTokenString:testToken
                                                              permissions:@[]
                                                      declinedPermissions:@[]
                                                       expiredPermissions:@[]
                                                                    appID:@"testAppId"
                                                                   userID:@"testUserId"
                                                           expirationDate:nil
                                                              refreshDate:nil
                                                 dataAccessExpirationDate:nil];
  id mockToken = OCMPartialMock(token);
  FBSDKLoginManagerLoginResult *result = [[FBSDKLoginManagerLoginResult alloc] initWithToken:mockToken
                                                                                 isCancelled:YES
                                                                          grantedPermissions:[NSSet set]
                                                                         declinedPermissions:[NSSet set]];
  [self.provider configureLoginManager:result withError:nil];

  XCTestExpectation *expectation = [self expectationWithDescription:@"logged in"];
  [self.provider signInWithDefaultValue:nil
               presentingViewController:nil
                             completion:^(FIRAuthCredential *_Nullable credential,
                                          NSError *_Nullable error,
                                          FIRAuthResultCallback _Nullable result,
                                          NSDictionary *_Nullable userInfo) {
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
  [self.provider signInWithDefaultValue:nil
               presentingViewController:nil
                             completion:^(FIRAuthCredential *_Nullable credential,
                                          NSError *_Nullable error,
                                          FIRAuthResultCallback _Nullable result,
                                          NSDictionary *_Nullable userInfo) {
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
  id mockProvider = OCMPartialMock([[FUIFacebookAuth alloc] initWithAuthUI:self.authUI]);
  id mockFacebookManager = OCMClassMock([FBSDKLoginManager class]);

  OCMExpect([mockProvider createLoginManager]).andReturn(mockFacebookManager);
  [mockProvider configureProvider];

  OCMExpect([mockFacebookManager logOut]);
  [mockProvider signOut];

  OCMVerifyAll(mockFacebookManager);
  OCMVerifyAll(mockProvider);

}

- (void)testUseEmulatorUsesOAuthProvider {
  [self.authUI useEmulatorWithHost:@"host" port:12345];
  self.provider = [[FUIFacebookAuthTest alloc] initWithAuthUI:self.authUI];

  [self.provider signInWithDefaultValue:nil
               presentingViewController:nil
                             completion:^(FIRAuthCredential *_Nullable credential,
                                          NSError *_Nullable error,
                                          FIRAuthResultCallback _Nullable result,
                                          NSDictionary *_Nullable userInfo) {}];
  OCMVerify([self.mockOAuthProvider getCredentialWithUIDelegate:nil completion:OCMOCK_ANY]);
}

@end
