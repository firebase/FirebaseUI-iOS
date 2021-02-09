//
//  Copyright (c) 2019 Google Inc.
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

#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>

#import <FirebaseAuth/FirebaseAuth.h>
#import <FirebaseCore/FirebaseCore.h>
#import <FirebaseUI/FirebaseAuthUI.h>

#import "FUIOAuth.h"

@interface FirebaseOAuthUITests : XCTestCase
@property (nonatomic, strong) FUIOAuth *provider;
@property (nonatomic, strong) FUIAuth *authUI;
@property (nonatomic, strong) id mockOAuthProvider;
@end

@implementation FirebaseOAuthUITests

- (void)setUp {
  [super setUp];

  id mockUtilsClass = OCMClassMock([FUIAuthUtils class]);
  OCMStub(ClassMethod([mockUtilsClass bundleNamed:OCMOCK_ANY])).
      andReturn([NSBundle bundleForClass:[FUIOAuth class]]);

  id authClass = OCMClassMock([FIRAuth class]);
  OCMStub(ClassMethod([authClass auth])).
      andReturn(authClass);

  id appClass = OCMClassMock([FIRApp class]);
  OCMStub([authClass app]).andReturn(appClass);

  self.mockOAuthProvider = OCMClassMock([FIROAuthProvider class]);
  OCMStub(ClassMethod([_mockOAuthProvider providerWithProviderID:OCMOCK_ANY])).
      andReturn(_mockOAuthProvider);

  FIRAuth *auth = [FIRAuth auth];
  self.authUI = [FUIAuth authUIWithAuth:auth];
}

- (void)tearDown {
  self.provider = nil;
  self.authUI = nil;
  self.mockOAuthProvider = nil;
  [super tearDown];
}

- (void)testProviderValidity {
  self.provider = [[FUIOAuth alloc] initWithAuthUI:self.authUI
                                        providerID:@"dummy"
                                   buttonLabelText:@"Sign in with dummy"
                                         shortName:@"Dummy"
                                       buttonColor:[UIColor clearColor]
                                         iconImage:[UIImage imageNamed:@""]
                                            scopes:@[]
                                  customParameters:@{}
                                      loginHintKey:nil];

  XCTAssertNotNil(self.provider);
  XCTAssertNil(self.provider.icon);
  XCTAssertNotNil(self.provider.signInLabel);
  XCTAssertNotNil(self.provider.buttonBackgroundColor);
  XCTAssertNotNil(self.provider.buttonTextColor);
  XCTAssertNotNil(self.provider.providerID);
  XCTAssertNotNil(self.provider.shortName);
  XCTAssertTrue(self.provider.signInLabel.length != 0);
  XCTAssertNil(self.provider.accessToken);
  XCTAssertNil(self.provider.idToken);

  OCMVerify([self.mockOAuthProvider providerWithProviderID:@"dummy"]);
}

- (void)testAppleUsesEmulatorCreatesOAuthProvider {
  [self.authUI useEmulatorWithHost:@"host" port:12345];

  self.provider = [[FUIOAuth alloc] initWithAuthUI:self.authUI
                                        providerID:@"apple.com"
                                   buttonLabelText:@"Sign in with Apple"
                                         shortName:@"Apple"
                                       buttonColor:[UIColor clearColor]
                                         iconImage:[UIImage imageNamed:@""]
                                            scopes:@[]
                                  customParameters:@{}
                                      loginHintKey:nil];
  OCMVerify([self.mockOAuthProvider providerWithProviderID:@"apple.com"]);
}

- (void)testAppleNoUseEmulatorNoOAuthProvider {
  self.provider = [[FUIOAuth alloc] initWithAuthUI:self.authUI
                                        providerID:@"apple.com"
                                   buttonLabelText:@"Sign in with Apple"
                                         shortName:@"Apple"
                                       buttonColor:[UIColor clearColor]
                                         iconImage:[UIImage imageNamed:@""]
                                            scopes:@[]
                                  customParameters:@{}
                                      loginHintKey:nil];
  OCMVerify(never(), [self.mockOAuthProvider providerWithProviderID:@"apple.com"]);
}

@end
