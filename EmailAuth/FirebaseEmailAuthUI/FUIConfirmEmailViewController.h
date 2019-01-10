//
//  Copyright (c) 2018 Google Inc.
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

#import "FUIAuthBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

/** @class FUIConfirmEmailViewController
    @brief The view controller that asks for user's email address.
 */
@interface FUIConfirmEmailViewController : FUIAuthBaseViewController

/** @fn onNext:
    @brief Should be called when user entered email. Triggers email verification before
        pushing new controller
    @param emailText Email value entered by user.
 */
- (void)onNext:(NSString *)emailText;

/** @fn didChangeEmail:
    @brief Update UI control state according to the email provided. Should be called after any
        change of email.
    @param emailText Email value entered by user.
 */
- (void)didChangeEmail:(NSString *)emailText;

@end

NS_ASSUME_NONNULL_END
