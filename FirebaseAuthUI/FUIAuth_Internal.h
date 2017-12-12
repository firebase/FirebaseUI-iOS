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

NS_ASSUME_NONNULL_BEGIN

@interface FUIAuth ()

/** @fn invokeResultCallbackWithAuthDataResult:error:
    @brief Invokes the auth UI result callback.
    @param authDataResult The sign in data result, if any.
    @param error The error which occurred, if any.
 */
- (void)invokeResultCallbackWithAuthDataResult:(nullable FIRAuthDataResult *)authDataResult
                                         error:(nullable NSError *)error;

/** @fn invokeOperationCallback:error:
    @brief Invokes the auth UI operation callback.
    @param operation The executed operation.
    @param error The error which occurred, if any.
 // TODO: Assistant Settings will be released later.
- (void)invokeOperationCallback:(FUIAccountSettingsOperationType)operation
                          error:(NSError *_Nullable)error;
 */

/** @fn providerWithID:
    @brief Returns first provider (if it exists) with specified provider ID.
    @param providerID The ID of the provider.
 */
- (nullable id<FUIAuthProvider>)providerWithID:(NSString *)providerID;

/** @fn signInWithProviderUI:presentingViewController:defaultValue:
    @brief Signs in with specified provider.
        @see FUIAuthDelegate.authUI:didSignInWithAuthDataResult:error: for method callback.
    @param providerUI The authentication provider used for signing in.
    @param presentingViewController The view controller used to present the UI.
    @param defaultValue The provider default initialization value (e g email or phone number)
        used for signing in.
 */
- (void)signInWithProviderUI:(id<FUIAuthProvider>)providerUI
    presentingViewController:(UIViewController *)presentingViewController
                defaultValue:(nullable NSString *)defaultValue;

@end

NS_ASSUME_NONNULL_END
