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

#import "FUIAuth.h"

@class FUIAuthBaseViewController;

/** @typedef FUIEmailHintSignInCallback
    @brief The type of block invoked when an emailHint sign-in event completes.

    @param authResult Optionally; Result of sign-in request containing both the user and
       the additional user info associated with the user.
    @param error Optionally; the error which occurred - or nil if the request was successful.
    @param credential Optionally; The credential used to sign-in.
 */
typedef void (^FUIEmailHintSignInCallback)(FIRAuthDataResult *_Nullable authResult,
                                           NSError *_Nullable error,
                                           FIRAuthCredential *_Nullable credential);

NS_ASSUME_NONNULL_BEGIN


/**
 * The methods defined in this file are for use in the FirebaseUI provider libraries.
 * They may break in non-major releases and are not for public use.
 */
@protocol FUIEmailAuthProvider <NSObject>

- (void)handleAccountLinkingForEmail:(NSString *)email
                       newCredential:(FIRAuthCredential *)newCredential
            presentingViewController:(UIViewController *)presentingViewController
                        signInResult:(_Nullable FIRAuthResultCallback)result;

- (void)signInWithEmailHint:(NSString *)emailHint
   presentingViewController:(FUIAuthBaseViewController *)presentingViewController
              originalError:(NSError *)originalError
                 completion:(FUIEmailHintSignInCallback)completion;

@end

@interface FUIAuth ()

/** @fn invokeResultCallbackWithAuthDataResult:error:
    @brief Invokes the auth UI result callback.
    @param authDataResult The sign in data result, if any.
    @param url The url, if any.
    @param error The error which occurred, if any.
 */
- (void)invokeResultCallbackWithAuthDataResult:(nullable FIRAuthDataResult *)authDataResult
                                           URL:(nullable NSURL *)url
                                         error:(nullable NSError *)error;

/** @fn invokeOperationCallback:error:
    @brief Invokes the auth UI operation callback.
    @param operation The executed operation.
    @param error The error which occurred, if any.
 */
- (void)invokeOperationCallback:(FUIAccountSettingsOperationType)operation
                          error:(NSError *_Nullable)error;


/** @fn providerWithID:
    @brief Returns first provider (if it exists) with specified provider ID.
    @param providerID The ID of the provider.
 */
- (nullable id<FUIAuthProvider>)providerWithID:(NSString *)providerID;

/** @fn signInWithProviderUI:presentingViewController:defaultValue:
    @brief Signs in with specified provider.
        @see FUIAuthDelegate.authUI:didSignInWithAuthDataResult:URL:error: for method callback.
    @param providerUI The authentication provider used for signing in.
    @param presentingViewController The view controller used to present the UI.
    @param defaultValue The provider default initialization value (e.g. email or phone number)
        used for signing in.
 */
- (void)signInWithProviderUI:(id<FUIAuthProvider>)providerUI
    presentingViewController:(UIViewController *)presentingViewController
                defaultValue:(nullable NSString *)defaultValue;

/** @property emailAuthProvider
    @brief The email auth provider, if any, that will be displayed in the default sign-in UI.
 */
@property(nonatomic, weak, nullable) id<FUIEmailAuthProvider> emailAuthProvider;

/** @property emulatorEnabled
    @brief Whether or not the auth emulator is being used.
 */
@property(nonatomic, assign, getter=isEmulatorEnabled) BOOL emulatorEnabled;

@end

NS_ASSUME_NONNULL_END
