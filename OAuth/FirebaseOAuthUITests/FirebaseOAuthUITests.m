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
#import <FirebaseUI/FirebaseAuthUI.h>

#import "FUIOAuth.h"

@interface FirebaseOAuthUITests : XCTestCase
@property (nonatomic, strong) FUIOAuth *provider;
@end

@implementation FirebaseOAuthUITests

- (void)setUp {
  [super setUp];

  id mockUtilsClass = OCMClassMock([FUIAuthUtils class]);
  OCMStub(ClassMethod([mockUtilsClass bundleNamed:OCMOCK_ANY])).
      andReturn([NSBundle bundleForClass:[FUIOAuth class]]);
  
  id authUIClass = OCMClassMock([FUIAuth class]);
  id providerIDClass = OCMClassMock([NSString class]);
  OCMStub(ClassMethod([authUIClass authUIWithAuth:OCMOCK_ANY])).
      andReturn(authUIClass);

  id authClass = OCMClassMock([FIRAuth class]);
  OCMStub(ClassMethod([authClass auth])).
      andReturn(authClass);

  FIRAuth *auth = [FIRAuth auth];
  FUIAuth *authUI = [FUIAuth authUIWithAuth:auth];

  self.provider = [[FUIOAuth alloc] initWithAuthUI:authUI
                                        providerID:@"dummy"
                                   buttonLabelText:@"Sign in with dummy"
                                         shortName:@"Dummy"
                                       buttonColor:[UIColor clearColor]
                                         iconImage:[UIImage imageNamed:@""]
                                            scopes:@[]
                                  customParameters:@{}
                                      loginHintKey:nil];
}

- (void)tearDown {
  self.provider = nil;
  [super tearDown];
}

- (void)testProviderValidity {
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
}

@end
