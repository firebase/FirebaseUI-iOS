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

#import "FIRAuthUI.h"

#import <objc/runtime.h>

#import <FirebaseAnalytics/FIRApp.h>
#import <FirebaseAuth/FIRAuth.h>
#import "FIRAuthPickerViewController.h"
#import "FIRAuthUI_Internal.h"

/** @var kAppNameCodingKey
    @brief The key used to encode the app Name for NSCoding.
 */
static NSString *const kAppNameCodingKey = @"appName";

/** @var kAuthAssociationKey
    @brief The address of this variable is used as the key for associating FIRAuthUI instances with
        root FIRAuth objects.
 */
static const char kAuthAssociationKey;

@interface FIRAuthUI ()

/** @fn initWithAuth:
    @brief auth The @c FIRAuth to associate the @c FIRAuthUI instance with.
 */
- (nullable instancetype)initWithAuth:(FIRAuth *)auth NS_DESIGNATED_INITIALIZER;

@end

@implementation FIRAuthUI

+ (nullable FIRAuthUI *)defaultAuthUI {
  FIRAuth *defaultAuth = [FIRAuth auth];
  if (!defaultAuth) {
    return nil;
  }
  return [self authUIWithAuth:defaultAuth];
}

+ (nullable FIRAuthUI *)authUIWithAuth:(FIRAuth *)auth {
  NSParameterAssert(auth != nil);
  @synchronized (self) {
    // Let the FIRAuth instance retain the FIRAuthUI instance.
    FIRAuthUI *authUI = objc_getAssociatedObject(auth, &kAuthAssociationKey);
    if (!authUI) {
      authUI = [[FIRAuthUI alloc] initWithAuth:auth];
      objc_setAssociatedObject(auth, &kAuthAssociationKey, authUI,
          OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return authUI;
  }
}

- (instancetype)initWithAuth:(FIRAuth *)auth {
  self = [super init];
  if (self) {
    _auth = auth;
  }
  return self;
}

- (BOOL)handleOpenURL:(NSURL *)URL
    sourceApplication:(NSString *)sourceApplication {
  // Complete IDP-based sign-in flow.
  for (id<FIRAuthProviderUI> provider in _providers) {
    if ([provider handleOpenURL:URL sourceApplication:sourceApplication]) {
      return YES;
    }
  }
  // The URL was not meant for us.
  return NO;
}

- (UIViewController *)authViewController {
  UIViewController *controller;
  if ([self.delegate respondsToSelector:@selector(authPickerViewControllerForAuthUI:)]) {
    controller = [self.delegate authPickerViewControllerForAuthUI:self];
  } else {
    controller = [[FIRAuthPickerViewController alloc] initWithAuthUI:self];
  }
  return [[UINavigationController alloc] initWithRootViewController:controller];
}

#pragma mark - Internal Methods

- (void)invokeResultCallbackWithUser:(FIRUser *_Nullable)user error:(NSError *_Nullable)error {
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.delegate authUI:self didSignInWithUser:user error:error];
  });
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
  return YES;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
  NSString *appName = [aDecoder decodeObjectOfClass:[NSString class] forKey:kAppNameCodingKey];
  if (!appName) {
    return nil;
  }
  FIRApp *app = [FIRApp appNamed:appName];
  if (!app) {
    return nil;
  }
  FIRAuth *auth = [FIRAuth authWithApp:app];
  if (!auth) {
    return nil;
  }
  return [self initWithAuth:auth];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [aCoder encodeObject:_auth.app.name forKey:kAppNameCodingKey];
}

@end
