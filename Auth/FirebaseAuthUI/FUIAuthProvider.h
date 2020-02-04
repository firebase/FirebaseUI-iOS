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
#import <FirebaseAuth/FirebaseAuth.h>

@class FIRAuth;
@class FIRAuthCredential;
@class FIRUserInfo;

NS_ASSUME_NONNULL_BEGIN

/** @typedef FUIAuthProviderSignInCompletionBlock
    @brief The type of block used to notify the auth system of the result of a sign-in flow.
        @see FUIAuthProvider.signInWithDefaultValue:presentingViewController:completion:
    @param credential The @c FIRAuthCredential object created after user interaction with third 
        party provider.
    @param error The error which may happen during creation of The @c FIRAuthCredential object.
    @param result The result of sign-in operation using provided @c FIRAuthCredential object.
        @see @c FIRAuth.signInWithCredential:completion:
    @param userInfo A dictionary containing additional information about the sign in operation.
        @see FUIAuthProviderSignInUserInfoKey
 */
typedef void (^FUIAuthProviderSignInCompletionBlock) (
    FIRAuthCredential *_Nullable credential,
    NSError *_Nullable error,
    _Nullable FIRAuthResultCallback result,
    NSDictionary<NSString *, id> *_Nullable userInfo);

/**
    @typedef FUIAuthProviderSignInUserInfoKey
    @brief A key in a userInfo dictionary corresponding to some supplemental value from
        the sign-in operation.
    @see FUIAuthProviderSignInCompletionBlock
 */
typedef NSString *FUIAuthProviderSignInUserInfoKey NS_TYPED_ENUM;

/**
   @typedef FUIButtonAlignment
   @brief The alignment of the icon and text of the button.
*/
typedef NS_ENUM(NSInteger, FUIButtonAlignment) {
    FUIButtonAlignmentLeading,
    FUIButtonAlignmentCenter,
};

/**
    For Firebase-based authentication operations, use this key to obtain the original auth result
    that was returned from the sign-in operation.
 */
static FUIAuthProviderSignInUserInfoKey FUIAuthProviderSignInUserInfoKeyAuthDataResult =
    @"FUIAuthProviderSignInUserInfoKeyAuthDataResult";

/** @protocol FUIAuthProvider
    @brief Represents an authentication provider (such as Google Sign In or Facebook Login) which
        can be used with the AuthUI classes (like @c FUIAuthPickerViewController).
    @remarks @c FUIAuth.signInProviders is populated with a list of @c FUIAuthProvider instances
        to provide users with sign-in options.
 */
@protocol FUIAuthProvider <NSObject>

/** @property providerID
    @brief A unique identifier for the provider.
 */
@property(nonatomic, copy, readonly, nullable) NSString *providerID;

/** @property shortName
    @brief A short display name for the provider.
 */
@property(nonatomic, copy, readonly) NSString *shortName;

/** @property signInLabel
    @brief A localized label for the provider's sign-in button.
 */
@property(nonatomic, copy, readonly) NSString *signInLabel;

/** @property icon
    @brief The icon image of the provider.
 */
@property(nonatomic, strong, readonly) UIImage *icon;

/** @property buttonBackgroundColor
    @brief The background color that should be used for the sign in button of the provider.
 */
@property(nonatomic, strong, readonly) UIColor *buttonBackgroundColor;

/** @property buttonTextColor
    @brief The text color that should be used for the sign in button of the provider.
 */
@property(nonatomic, strong, readonly) UIColor *buttonTextColor;

/** @property buttonAlignment
    @brief The alignment of the icon and text of the button.
 */
@property(nonatomic, readwrite) FUIButtonAlignment buttonAlignment;

/** @fn signInWithEmail:presentingViewController:completion:
    @brief Called when the user wants to sign in using this auth provider.
    @remarks Implementors should invoke the completion block when the sign-in process has terminated
        or is canceled. There are two valid combinations of parameters; either @c credentials and
        @c userInfo are both non-nil, or @c error is non-nil. Errors must specify an error code
        which is one of the @c FIRAuthErrorCode codes. It is very important that all possible code
        paths eventually call this method to inform the auth system of the result of the sign-in
        flow.
    @param email The email address of the user if it's known.
    @param presentingViewController The view controller used to present the UI.
    @param completion See remarks. A block which should be invoked when the sign-in process 
        (using @c FIRAuthCredential) completes.
 */
- (void)signInWithEmail:(nullable NSString *)email
    presentingViewController:(nullable UIViewController *)presentingViewController
                  completion:(nullable FUIAuthProviderSignInCompletionBlock)completion
__attribute__((deprecated("This is deprecated API and will be removed in a future release."
                          "Use signInWithDefaultValue:presentingViewController:completion:")));

/** @fn signInWithDefaultValue:presentingViewController:completion:
    @brief Called when the user wants to sign in using this auth provider.
    @remarks Implementors should invoke the completion block when the sign-in process has terminated
        or is canceled. There are two valid combinations of parameters; either @c credentials and
        @c userInfo are both non-nil, or @c error is non-nil. Errors must specify an error code
        which is one of the @c FIRAuthErrorCode codes. It is very important that all possible code
        paths eventually call this method to inform the auth system of the result of the sign-in
        flow.
    @param defaultValue The default initialization value of the provider (email, phone number etc.).
    @param presentingViewController The view controller used to present the UI.
    @param completion See remarks. A block which should be invoked when the sign-in process 
        (using @c FIRAuthCredential) completes.
 */
- (void)signInWithDefaultValue:(nullable NSString *)defaultValue
      presentingViewController:(nullable UIViewController *)presentingViewController
                    completion:(nullable FUIAuthProviderSignInCompletionBlock)completion;

/** @fn signOut
    @brief Called when the user wants to sign out.
 */
- (void)signOut;

/** @property accessToken
    @brief User Access Token obtained during sign in.
 */
@property(nonatomic, copy, readonly, nullable) NSString *accessToken;

@optional;

/** @property idToken
    @brief User Id Token obtained during sign in. Not all providers can return, thus it's optional.
 */
@property(nonatomic, copy, readonly, nullable) NSString *idToken;

/** @fn email
    @brief The email address associated with this provider, if any.
 */
- (NSString *)email;

/** @fn handleOpenURL:
    @brief May be used to help complete a sign-in flow which requires a callback from Safari.
    @param URL The URL which may be handled by the auth provider if an URL is expected.
    @param sourceApplication The application which tried opening the URL.
    @return YES if your auth provider handled the URL. NO otherwise.
 */
- (BOOL)handleOpenURL:(NSURL *)URL sourceApplication:(nullable NSString *)sourceApplication;

@end

NS_ASSUME_NONNULL_END
