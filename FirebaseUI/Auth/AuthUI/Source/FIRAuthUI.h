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
@class FIRAuthPickerViewController;
@class FIRAuthUI;
@class FIRUser;

NS_ASSUME_NONNULL_BEGIN

/** @typedef FIRAuthUIResultCallback
    @brief The type of block invoked when sign-in related events complete.
    @param user The user signed in, if any.
    @param error The error which occurred, if any.
 */
typedef void (^FIRAuthUIResultCallback)(FIRUser *_Nullable user, NSError *_Nullable error);

/** @protocol FIRAuthUIDelegate
    @brief A delegate that receives callbacks or provides custom UI for @c FIRAuthUI.
 */
@protocol FIRAuthUIDelegate <NSObject>

/** @fn authUI:didSignInWithUser:error:
    @brief Message sent after the sign in process has completed to report the signed in user or
        error encountered.
    @param authUI The @c FIRAuthUI instance sending the messsage.
    @param user The signed in user if the sign in attempt was successful.
    @param error The error that occured during sign in, if any.
 */
- (void)authUI:(FIRAuthUI *)authUI didSignInWithUser:(nullable FIRUser *)user error:(nullable NSError *)error;

@optional

/** @fn authPickerViewControllerForAuthUI:
    @brief Sent to the receiver to ask for an instance of @c FIRAuthPickerViewController subclass
        to allow UI customizations.
    @param authUI The @c FIRAuthUI instance sending the message.
    @return an instance of @c FIRAuthPickerViewController subclass.
 */
- (FIRAuthPickerViewController *)authPickerViewControllerForAuthUI:(FIRAuthUI *)authUI;

@end

/** @class FIRAuthUI
    @brief Provides various iOS UIs for Firebase Auth.
 */
@interface FIRAuthUI : NSObject <NSSecureCoding>

/** @fn authUI
    @brief Gets the @c FIRAuthUI object for the default FirebaseApp.
    @remarks Thread safe.
 */
+ (nullable FIRAuthUI *)defaultAuthUI;

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

/** @property providers
    @brief The @c FIRAuthProviderUI implementations to use for sign-in.
 */
@property(nonatomic, copy) NSArray<id<FIRAuthProviderUI>> *providers;

/** @property signInWithEmailHidden
    @brief Whether to hide the "Sign in with email" option, defaults to NO.
 */
@property(nonatomic, assign, getter=isSignInWithEmailHidden) BOOL signInWithEmailHidden;

/** @property customStringsBundle
    @brief Custom strings bundle supplied by the developer. Nil when there is no custom strings
        bundle set. In which case the default bundle will be used.
    @remarks Set this property to nil in order to remove the custom strings bundle and revert to
        using the default bundle.
 */
@property(nonatomic, strong, nullable) NSBundle *customStringsBundle;

/** @property TOSURL
    @brief The URL of your app's Terms of Service. If not nil, a Terms of Service notice is
        displayed on the email/password account creation screen.
 */
@property(nonatomic, copy, nullable) NSURL *TOSURL;

/** @property delegate
    @brief A delegate that receives callbacks or provides custom UI for @c FIRAuthUI.
 */
@property(nonatomic, weak) id<FIRAuthUIDelegate> delegate;

/** @fn init
    @brief Please use @c FIRAuthUI.authUIWithAuth to get a @c FIRAuthUI instance.
 */
- (nullable instancetype)init NS_UNAVAILABLE;

/** @fn handleOpenURL:
    @brief Should be called from your @c UIApplicationDelegate in
        @c UIApplicationDelegate.application:openURL:options: to finish sign-in flows.
    @param URL The URL which may be handled by Firebase Auth UI if an URL is expected.
    @param sourceApplication The application which tried opening the URL.
    @return YES if Firebase Auth UI handled the URL. NO otherwise.
 */
- (BOOL)handleOpenURL:(NSURL *)URL
    sourceApplication:(nullable NSString *)sourceApplication;

/** @fn authViewController
    @brief Returns an instance of the initial view controller of AuthUI.
    @return An instance of the the initial view controller of AuthUI.
 */
- (UIViewController *)authViewController;

@end

NS_ASSUME_NONNULL_END
