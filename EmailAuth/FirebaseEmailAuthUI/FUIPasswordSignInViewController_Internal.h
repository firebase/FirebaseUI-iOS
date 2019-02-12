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

/** @property onDismissCallback:
    @brief Sets an optional custom callback for FUIPasswordSigInViewController during dismissal. This block is NOT set to nil after use, set to nil after using
        if you wish to avoid circular references.
 */
@property(nonatomic, strong, nullable) FIRAuthDataResultCallback onDismissCallback;

NS_ASSUME_NONNULL_END


@end
