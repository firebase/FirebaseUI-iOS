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

/** @fn invokeResultCallbackWithUser:error:
    @brief Invokes the auth UI result callback.
    @param user The user signed in, if any.
    @param error The error which occurred, if any.
 */
- (void)invokeResultCallbackWithUser:(FIRUser *_Nullable)user error:(NSError *_Nullable)error;

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

/** @fn signOutWithError:
    @brief Signs in with specified provider. @see FUIAuthDelegate.authUI:didSignInWithUser:error: 
        for method callback.
    @param providerUI The authentication provider used for signing in.
    @param delegate The UI delegate which handles UI operations.
    @param shownWithoutAuthPicker Defines if sign in flow was shown without 
        @c FUIAuthPickerViewController.
 */
- (void)signInWithProviderUI:(id<FUIAuthProvider>)providerUI
            signInUIDelegate:(id<FUIAuthSignInUIDelegate>)delegate
      shownWithoutAuthPicker:(BOOL)shownWithoutAuthPicker;

@end

NS_ASSUME_NONNULL_END
