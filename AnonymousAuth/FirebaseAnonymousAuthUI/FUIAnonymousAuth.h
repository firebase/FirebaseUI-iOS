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
@class FUIAuth;
#import <FirebaseUI/FUIAuthProvider.h>

NS_ASSUME_NONNULL_BEGIN

/** @class FUIAnonymousAuth
    @brief AuthUI components for Anonymous Sign In.
 */
@interface FUIAnonymousAuth : NSObject <FUIAuthProvider>

/** @fn init
    @brief Initialize the instance with the default AuthUI. 
 */
- (instancetype)init;

/** @fn initWithAuthUI:
    @param authUI The @c FUIAuth instance that manages controllers of this provider.
 */
- (instancetype)initWithAuthUI:(FUIAuth *)authUI NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
