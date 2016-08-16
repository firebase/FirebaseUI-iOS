//
//  FIRAuthUITest.m
//  FirebaseUI
//
//  Created by Morgan Chen on 8/15/16.
//  Copyright © 2016 Firebase, Inc. All rights reserved.
//

@import XCTest;
@import Firebase;
@import FirebaseAuth;

#import "FIRAuthUI.h"
#import "FIRAuthUIUtils.h"
#import "FIRAuthPickerViewController.h"

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
  [FIRApp configure];
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
