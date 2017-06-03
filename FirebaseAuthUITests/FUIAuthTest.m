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
@import FirebaseAnalytics;
@import FirebaseAuth;
@import FirebaseAuthUI;
#import <OCMock/OCMock.h>
#import "FUIAuthUtils.h"

@interface FUILoginProvider : NSObject <FUIAuthProvider>
@property (nonatomic, assign) BOOL canHandleURLs;
@end

@implementation FUILoginProvider

- (NSString *)providerID  { return @"provider id"; }
- (NSString *)shortName   { return @"login provider"; }
- (NSString *)signInLabel { return @"sign in label"; }
- (NSString *)accessToken { return @"accessToken"; }
- (NSString *)idToken     { return @"idToken"; }

- (UIImage *)icon {
  return [[UIImage alloc] init];
}

- (UIColor *)buttonBackgroundColor {
  return [UIColor clearColor];
}

- (UIColor *)buttonTextColor {
  return [UIColor whiteColor];
}

- (void)signInWithEmail:(NSString *)email
  presentingViewController:(UIViewController *)presentingViewController
            completion:(FIRAuthProviderSignInCompletionBlock)completion {}

- (void)signOut {}

- (BOOL)handleOpenURL:(NSURL *)URL sourceApplication:(NSString *)sourceApplication {
  return self.canHandleURLs;
}

@end

@interface FUIAuthUIDelegate : NSObject <FUIAuthDelegate>
@end

@implementation FUIAuthUIDelegate
- (void)authUI:(FUIAuth *)authUI didSignInWithUser:(FIRUser *)user error:(NSError *)error {
}

- (FUIAuthPickerViewController *)authPickerViewControllerForAuthUI:(FUIAuth *)authUI {
  Class controllerClass = [FUIAuthPickerViewController class];
  NSString *classString = NSStringFromClass(controllerClass);
  NSBundle *bundle = [NSBundle bundleForClass:controllerClass];
  return [[FUIAuthPickerViewController alloc] initWithNibName:classString
                                                             bundle:bundle
                                                             authUI:authUI];
}
@end

@interface FUIAuthTest : XCTestCase
@property (nonatomic) FIRAuth *auth;
@property (nonatomic) FUIAuth *authUI;
@property (nonatomic) FUIAuthUIDelegate *delegate;
@end

@implementation FUIAuthTest

- (void)setUp {
  [super setUp];
  id authClass = OCMClassMock([FIRAuth class]);
  OCMStub(ClassMethod([authClass auth])).
      andReturn(authClass);

  id mockUtilsClass = OCMClassMock([FUIAuthUtils class]);
  OCMStub(ClassMethod([mockUtilsClass bundleNamed:OCMOCK_ANY])).
      andReturn([NSBundle bundleForClass:[FUIAuth class]]);

  self.auth = [FIRAuth auth];
  self.authUI = [FUIAuth defaultAuthUI];
  self.delegate = [[FUIAuthUIDelegate alloc] init];
}

- (void)tearDown {
  [super tearDown];
  self.delegate = nil;
}

- (void)testItExists {
  XCTAssert(self.auth != nil, @"expected default auth instance to exist");
  XCTAssert(self.authUI != nil, @"expected default authUI instance to exist");
}

- (void)testItProducesAViewController {
  self.authUI.delegate = self.delegate;
  UIViewController *controller = [self.authUI authViewController];
  XCTAssert(controller != nil, @"expected authUI to produce nonnull view controller");
}

- (void)testItAsksAuthProvidersWhenHandlingURLs {
  FUILoginProvider *provider = [[FUILoginProvider alloc] init];
  self.authUI.providers = @[provider];
  provider.canHandleURLs = NO;
  BOOL handled = [self.authUI handleOpenURL:[NSURL URLWithString:@"https://google.com/"]
                          sourceApplication:nil];
  XCTAssert(handled == NO, @"expected authUI with no providers that can handle open URLs to not handle opening URL");
  
  provider.canHandleURLs = YES;
  handled = [self.authUI handleOpenURL:[NSURL URLWithString:@"https://google.com/"]
                     sourceApplication:nil];
  XCTAssert(handled == YES, @"expected authUI with providers that can handle open URLs to handle opening URL");
}

@end
