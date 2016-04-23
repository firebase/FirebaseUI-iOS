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

#import <UIKit/UIKit.h>

#import "FIRAuthProviderUI.h"

@class FIRAuth;
@class FIRUser;

NS_ASSUME_NONNULL_BEGIN

/** @typedef FIRAuthUIResultCallback
    @brief The type of block invoked when sign-in related events complete.
    @param user The user signed in, if any.
    @param error The error which occurred, if any.
 */
typedef void (^FIRAuthUIResultCallback)(FIRUser *_Nullable user, NSError *_Nullable error);

/** @class FIRAuthUI
    @brief Provides various iOS UIs for Firebase Auth.
 */
@interface FIRAuthUI : NSObject <NSSecureCoding>

/** @fn authUI
    @brief Gets the @c FIRAuthUI object for the default FirebaseApp.
    @remarks Thread safe.
 */
+ (nullable FIRAuthUI *)authUI NS_SWIFT_NAME(authUI());

/** @fn authUIWithAuth:
    @brief Gets the @c FIRAuthUI instance for a @c FIRAuth.
    @param auth The @c FIRAuth for which to retrieve the associated @c FIRAuthUI instance.
    @return The @c FIRAuthUI instance associated with the given @c FIRAuth.
    @remarks Thread safe.
 */
+ (nullable FIRAuthUI *)authUIWithAuth:(FIRAuth *)auth;

/** @property app
    @brief Gets the @c FIRAuth this auth UI object is connected to.
 */
@property(nonatomic, weak, readonly, nullable) FIRAuth *auth;

/** @property signInProviders
    @brief The @c FIRAuthProviderUI implementations to use for sign-in.
 */
@property(nonatomic, copy) NSArray<id<FIRAuthProviderUI>> *signInProviders;

/** @fn init
    @brief Please use @c FIRAuthUI.authUIWithAuth to get a @c FIRAuthUI instance.
 */
- (nullable instancetype)init NS_UNAVAILABLE;

/** @fn presentSignInWithViewController:callback:
    @brief Presents the sign-in screen.
    @param viewController The view controller from which to present the sign-in view controller.
    @param callback A block to invoke when the sign-in process finishes, or is canceled. Invoked
        asynchronously on the main thread at some time in the future.
 */
- (void)presentSignInWithViewController:(UIViewController *)viewController
                               callback:(nullable FIRAuthUIResultCallback)callback;

/** @fn handleOpenURL:
    @brief Should be called from your @c UIApplicationDelegate in
        @c UIApplicationDelegate.application:openURL:options: to finish sign-in flows.
    @param URL The URL which may be handled by Firebase Auth UI if an URL is expected.
    @param sourceApplication The application which tried opening the URL.
    @return YES if Firebase Auth UI handled the URL. NO otherwise.
 */
- (BOOL)handleOpenURL:(NSURL *)URL
    sourceApplication:(NSString *)sourceApplication;

@end

NS_ASSUME_NONNULL_END
