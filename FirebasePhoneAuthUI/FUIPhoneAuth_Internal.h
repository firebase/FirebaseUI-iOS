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

#import "FUIPhoneAuth.h"

#import "FirebasePhoneAuthUI.h"
#import "FUIAuthBaseViewController_Internal.h"

NS_ASSUME_NONNULL_BEGIN

@interface FUIPhoneAuth (Internal)

/** @fn callbackWithCredential:error:
    @brief Ends the sign-in flow by cleaning up and calling back with given credential or error.
    @param credential The credential to pass back, if any.
    @param error The error to pass back, if any.
    @param result The result of sign-in operation using provided @c FIRAuthCredential object.
        @see @c FIRAuth.signInWithCredential:completion:
*/
- (void)callbackWithCredential:(nullable FIRAuthCredential *)credential
                         error:(nullable NSError *)error
                        result:(nullable FIRAuthResultCallback)result;

/** @fn alertControllerForError:actionHandler:
    @brief Creates alert controller for specified phone auth error.
    @param error The error which should be shown in alert.
    @param actionHandler The handler of alert action button, if any.
 */
+ (UIAlertController *)alertControllerForError:(NSError *)error
                                 actionHandler:(nullable FUIAuthAlertActionHandler)actionHandler;

@end

NS_ASSUME_NONNULL_END
