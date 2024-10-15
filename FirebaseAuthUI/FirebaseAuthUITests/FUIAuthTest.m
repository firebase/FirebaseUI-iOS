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
@import FirebaseAuth;
@import FirebaseCore;

#import "FUIAuth.h"
#import "FUIAuthUtils.h"
#import "FUIAuthPickerViewController.h"
#import <OCMock/OCMock.h>

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

- (FUIButtonAlignment)buttonAlignment {
  return FUIButtonAlignmentCenter;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"
- (void)signInWithEmail:(NSString *)email
  presentingViewController:(UIViewController *)presentingViewController
            completion:(FUIAuthProviderSignInCompletionBlock)completion {}
#pragma clang diagnostic pop

- (void)signOut {}

- (BOOL)handleOpenURL:(NSURL *)URL sourceApplication:(NSString *)sourceApplication {
  return self.canHandleURLs;
}

- (void)signInWithDefaultValue:(nullable NSString *)defaultValue
      presentingViewController:(nullable UIViewController *)presentingViewController
                    completion:(nullable FUIAuthProviderSignInCompletionBlock)completion {}


@end

@interface FUIAuthUIDelegate : NSObject <FUIAuthDelegate>
@end

@implementation FUIAuthUIDelegate
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"
- (void)authUI:(FUIAuth *)authUI didSignInWithUser:(FIRUser *)user error:(NSError *)error {
}
#pragma clang diagnostic pop

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

  if ([FIRApp defaultApp] == nil) {
    FIROptions *options = [[FIROptions alloc] initWithGoogleAppID:@"1:1069647793992:ios:91eecf4730fc920b"
                                                      GCMSenderID:@"1069647793992"];
    options.APIKey = @"fakeAPIKey";
    [FIRApp configureWithOptions:options];
  }

  self.auth = [FIRAuth authWithApp:[FIRApp defaultApp]];
  self.authUI = [FUIAuth authUIWithAuth:self.auth];
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

- (void)testUseEmulatorSetsFIRAuthEmulator {
  id mockAuth = OCMClassMock([FIRAuth class]);
  OCMStub(ClassMethod([mockAuth auth])).andReturn(mockAuth);

  self.authUI = [FUIAuth authUIWithAuth:mockAuth];
  [self.authUI useEmulatorWithHost:@"host" port:12345];

  OCMVerify([mockAuth useEmulatorWithHost:@"host" port:12345]);
}

- (void)testStringBySHA256HashingString {
  NSString *inputString = @"abc-123.ZYX_987";
  NSString *expectedSHA256HashedString = @"d858d78754a50c8ccdc414946f656fe854e6ba76bf09a79a7e7d9ca135e4b58d";

  NSString *actualSHA256HashedString = [FUIAuthUtils stringBySHA256HashingString:inputString];

  XCTAssertEqualObjects(actualSHA256HashedString, expectedSHA256HashedString);
}

@end
