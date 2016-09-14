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

@interface FUILoginProvider : NSObject <FIRAuthProviderUI>
@property (nonatomic, assign) BOOL canHandleURLs;
@end

@implementation FUILoginProvider

- (NSString *)providerID  { return @"provider id"; }
- (NSString *)shortName   { return @"login provider"; }
- (NSString *)signInLabel { return @"sign in label"; }

- (UIImage *)icon {
  return [[UIImage alloc] init];
}

- (UIColor *)buttonBackgroundColor {
  return [UIColor clearColor];
}

- (UIColor *)buttonTextColor {
  return [UIColor whiteColor];
}

- (void)signInWithAuth:(FIRAuth *)auth
                 email:(NSString *)email
  presentingViewController:(UIViewController *)presentingViewController
            completion:(FIRAuthProviderSignInCompletionBlock)completion {}

- (void)signOutWithAuth:(FIRAuth *)auth {}

- (BOOL)handleOpenURL:(NSURL *)URL sourceApplication:(NSString *)sourceApplication {
  return self.canHandleURLs;
}

@end

@interface FUIAuthUIDelegate : NSObject <FIRAuthUIDelegate>
@end

@implementation FUIAuthUIDelegate
- (void)authUI:(FIRAuthUI *)authUI didSignInWithUser:(FIRUser *)user error:(NSError *)error {
}

- (FIRAuthPickerViewController *)authPickerViewControllerForAuthUI:(FIRAuthUI *)authUI {
  Class controllerClass = [FIRAuthPickerViewController class];
  NSString *classString = NSStringFromClass(controllerClass);
  NSBundle *bundle = [NSBundle bundleForClass:controllerClass];
  return [[FIRAuthPickerViewController alloc] initWithNibName:classString
                                                             bundle:bundle
                                                             authUI:authUI];
}
@end

@interface FIRAuthUITest : XCTestCase
@property (nonatomic) FIRAuth *auth;
@property (nonatomic) FIRAuthUI *authUI;
@property (nonatomic) FUIAuthUIDelegate *delegate;
@end

@implementation FIRAuthUITest

+ (void)initialize {
  // An app needs to be configured before any instances of
  // FIRAuth or FIRAuthUI can be created.
  
  // Load plist from test file
  NSBundle *bundle = [NSBundle bundleForClass:[self class]];
  NSString *file = [bundle pathForResource:@"GoogleService-Info"
                                    ofType:@"plist"];
  
  FIROptions *options = [[FIROptions alloc] initWithContentsOfFile:file];
  [FIRApp configureWithOptions:options];
}

- (void)setUp {
  [super setUp];
  self.auth = [FIRAuth auth];
  self.authUI = [FIRAuthUI defaultAuthUI];
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
