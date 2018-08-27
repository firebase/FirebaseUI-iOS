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

#import "FUIAccountSettingsOperationType.h"
#import "FUIAuthProvider.h"

@class FIRAuth;
@class FUIAuthPickerViewController;
@class FUIAuth;
@class FIRUser;
@class FUIEmailEntryViewController;
@class FUIPasswordSignInViewController;
@class FUIPasswordSignUpViewController;
@class FUIPasswordRecoveryViewController;
@class FUIPasswordVerificationViewController;

NS_ASSUME_NONNULL_BEGIN

/** @typedef FUIAuthResultCallback
    @brief The type of block invoked when sign-in related events complete.
    @param user The user signed in, if any.
    @param error The error which occurred, if any.
 */
typedef void (^FUIAuthResultCallback)(FIRUser *_Nullable user, NSError *_Nullable error);

/** @protocol FUIAuthDelegate
    @brief A delegate that receives callbacks or provides custom UI for @c FUIAuth.
 */
@protocol FUIAuthDelegate <NSObject>

@optional

/** @fn authUI:didSignInWithAuthDataResult:error:
    @brief Message sent after the sign in process has completed to report the signed in user or
        error encountered.
    @param authUI The @c FUIAuth instance sending the message.
    @param authDataResult The data result if the sign in attempt was successful.
    @param error The error that occurred during sign in, if any.
 */
- (void)authUI:(FUIAuth *)authUI
    didSignInWithAuthDataResult:(nullable FIRAuthDataResult *)authDataResult
                          error:(nullable NSError *)error;

/** @fn authUI:didSignInWithUser:error:
    @brief This is deprecated API and will be removed in a future release.
        Use @c authUI:didSignInWithAuthDataResult:error:
        Both sign in call backs are called (@c authUI:didSignInWithAuthDataResult:error:
        and @c authUI:didSignInWithUser:error:).
        This message is sent after the sign in process has completed to report the signed in user or
        error encountered.
    @param authUI The @c FUIAuth instance sending the message.
    @param user The signed in user if the sign in attempt was successful.
    @param error The error that occurred during sign in, if any.
 */
- (void)authUI:(FUIAuth *)authUI
    didSignInWithUser:(nullable FIRUser *)user
                error:(nullable NSError *)error
__attribute__((deprecated("Instead use authUI:didSignInWithAuthDataResult:error:")));


/** @fn authUI:didFinishOperation:error:
    @brief Message sent after finishing Account Management operation.
    @param authUI The @c FUIAuth instance sending the message.
    @param operation The operation type that was just completed.
    @param error The error that occurred during operation, if any.
*/
- (void)authUI:(FUIAuth *)authUI
    didFinishOperation:(FUIAccountSettingsOperationType)operation
                 error:(nullable NSError *)error;

/** @fn authPickerViewControllerForAuthUI:
    @brief Sent to the receiver to ask for an instance of @c FUIAuthPickerViewController subclass
        to allow UI customizations.
    @param authUI The @c FUIAuth instance sending the message.
    @return an instance of @c FUIAuthPickerViewController subclass.
 */
- (FUIAuthPickerViewController *)authPickerViewControllerForAuthUI:(FUIAuth *)authUI;

/** @fn emailEntryViewControllerForAuthUI:
    @brief Sent to the receiver to ask for an instance of @c FUIEmailEntryViewController subclass
    to allow UI customizations.
    @param authUI The @c FUIAuth instance sending the message.
    @return an instance of @c FUIEmailEntryViewController subclass.
 */
- (FUIEmailEntryViewController *)emailEntryViewControllerForAuthUI:(FUIAuth *)authUI;

/** @fn passwordSignInViewControllerForAuthUI:email:
    @brief Sent to the receiver to ask for an instance of @c FUIPasswordSignInViewController subclass
    to allow sign-in UI customizations.
    @param authUI The @c FUIAuth instance sending the message.
    @param email The email user is using for sin-in.
    @return an instance of @c FUIPasswordSignInViewController subclass.
 */
- (FUIPasswordSignInViewController *)passwordSignInViewControllerForAuthUI:(FUIAuth *)authUI
                                                                     email:(NSString *)email;

/** @fn passwordSignInViewControllerForAuthUI:email:
    @brief Sent to the receiver to ask for an instance of @c FUIPasswordSignUpViewController subclass
    to allow sign-up UI customizations.
    @param authUI The @c FUIAuth instance sending the message.
    @param email The email user is using for sin-in.
    @return an instance of @c FUIPasswordSignUpViewController subclass.
 */
- (FUIPasswordSignUpViewController *)passwordSignUpViewControllerForAuthUI:(FUIAuth *)authUI
                                                                     email:(NSString *)email;

/** @fn passwordRecoveryViewControllerForAuthUI:email:
    @brief Sent to the receiver to ask for an instance of @c FUIPasswordRecoveryViewController subclass
    to allow sign-up UI customizations.
    @param authUI The @c FUIAuth instance sending the message.
    @param email The email user is using for password recovery.
    @return an instance of @c FUIPasswordRecoveryViewController subclass.
 */
- (FUIPasswordRecoveryViewController *)passwordRecoveryViewControllerForAuthUI:(FUIAuth *)authUI
                                                                         email:(NSString *)email;

/** @fn passwordVerificationViewControllerForAuthUI:email:newCredential:
    @brief Sent to the receiver to ask for an instance of @c FUIPasswordVerificationViewController subclass
    to allow password verification UI customizations.
    @param authUI The @c FUIAuth instance sending the message.
    @param email The email user is using for sin-in.
    @param newCredential This @c FIRAuthCredential obtained from linked account.
    @return an instance of @c FUIPasswordVerificationViewController subclass.
 */
- (FUIPasswordVerificationViewController *)passwordVerificationViewControllerForAuthUI:(FUIAuth *)authUI
                                                                                 email:(NSString *)email
                                                                         newCredential:(FIRAuthCredential *)newCredential;
@end

/** @class FUIAuth
    @brief Provides various iOS UIs for Firebase Auth.
 */
@interface FUIAuth : NSObject <NSSecureCoding>

/** @fn defaultAuthUI
    @brief Gets the @c FUIAuth object for the default FirebaseApp.
    @remarks Thread safe.
 */
+ (nullable FUIAuth *)defaultAuthUI;

/** @fn authUIWithAuth:
    @brief Gets the @c FUIAuth instance for a @c FIRAuth.
    @param auth The @c FIRAuth for which to retrieve the associated @c FUIAuth instance.
    @return The @c FUIAuth instance associated with the given @c FIRAuth.
    @remarks Thread safe.
 */
+ (nullable FUIAuth *)authUIWithAuth:(FIRAuth *)auth;

/** @property app
    @brief Gets the @c FIRAuth this auth UI object is connected to.
 */
@property(nonatomic, weak, readonly, nullable) FIRAuth *auth;

/** @property providers
    @brief The @c FUIAuthProvider implementations to use for sign-in.
 */
@property(nonatomic, copy) NSArray<id<FUIAuthProvider>> *providers;

/** @property signInWithEmailHidden
    @brief Whether to hide the "Sign in with email" option, defaults to NO.
 */
@property(nonatomic, assign, getter=isSignInWithEmailHidden) BOOL signInWithEmailHidden;

/** @property allowNewEmailAccounts
 @brief Whether to allow new user sign, defaults to YES.
 */
@property(nonatomic, assign) BOOL allowNewEmailAccounts;

/** @property shouldHideCancelButton
 @brief Whether to hide the canel button, defaults to NO.
 */
@property(nonatomic, assign) BOOL shouldHideCancelButton;

/** @property customStringsBundle
    @brief Custom strings bundle supplied by the developer. Nil when there is no custom strings
        bundle set. In which case the default bundle will be used.
    @remarks Set this property to nil in order to remove the custom strings bundle and revert to
        using the default bundle.
 */
@property(nonatomic, strong, nullable) NSBundle *customStringsBundle;

/** @property TOSURL
    @brief The URL of your app's Terms of Service. If not nil, a Terms of Service notice is
        displayed on the initial sign-in screen and potentially the phone number auth and
        email/password account creation screen.
 */
@property(nonatomic, copy, nullable) NSURL *TOSURL;

/** @property shouldAutoUpgradeAnonymousUsers
    @brief Whether to enable auto upgrading of anonymous accounts, defaults to NO.
 */
@property(nonatomic, assign, getter=shouldAutoUpgradeAnonymousUsers) BOOL autoUpgradeAnonymousUsers;

/** @property privacyPolicyURL
    @brief The URL of your app's Privacy Policy. If not nil, a privacy policy notice is
        displayed on the initial sign-in screen and potentially the phone number auth and
        email/password account creation screen.
 */
@property(nonatomic, copy, nullable) NSURL *privacyPolicyURL;

/** @property delegate
    @brief A delegate that receives callbacks or provides custom UI for @c FUIAuth.
 */
@property(nonatomic, weak) id<FUIAuthDelegate> delegate;

/** @fn init
    @brief Please use @c FUIAuth.authUIWithAuth to get a @c FUIAuth instance.
 */
- (instancetype)init NS_UNAVAILABLE;

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
    @brief Returns an instance of the initial navigation view controller of AuthUI.
    @return An instance of the the initial navigation view controller of AuthUI.
 */
- (UINavigationController *)authViewController;

/** @fn signOutWithError:
    @brief Signs out the current user from Firebase and all providers.
    @param error Optionally; if an error occurs during Firebase sign out, upon return contains an
        NSError object that describes the problem; is nil otherwise. If Firebase error occurs all 
        providers are not logged-out and sign-out should be retried.
        @return @YES when the sign out request was successful. @NO otherwise.
        @remarks Possible error codes:
        - @c FIRAuthErrorCodeKeychainError Indicates an error occurred when accessing the keychain.
        The @c NSLocalizedFailureReasonErrorKey field in the @c NSError.userInfo dictionary
        will contain more information about the error encountered.
 */
- (BOOL)signOutWithError:(NSError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
