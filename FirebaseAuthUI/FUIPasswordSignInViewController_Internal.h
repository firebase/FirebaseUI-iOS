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

#import "FUIPasswordSignInViewController.h"
#import <FirebaseAuth/FirebaseAuth.h>

NS_ASSUME_NONNULL_BEGIN

@interface FUIPasswordSignInViewController ()

/** @fn setOnDismissCallback:
    @brief Sets an optional custom callback for FUIPasswordSigInViewController during dismissal. If
        this callback is set the default dismissal routine is not triggered and should be included
        in this block if necessary.
    @param callback The custom callback to execute during dismissal of the view controller.
 */
- (void)setOnDismissCallback:(FIRAuthDataResultCallback)callback;

NS_ASSUME_NONNULL_END


@end
