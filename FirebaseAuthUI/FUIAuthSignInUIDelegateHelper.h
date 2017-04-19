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

#import "FUIAuth_Internal.h"

NS_ASSUME_NONNULL_BEGIN

/** @class FUIAuthSignInUIDelegateHelper
    @brief Utility class which is used as wrapper of original @c FUIAuthSignInUIDelegate in order
        to verify if all methods can be called.
 */
@interface FUIAuthSignInUIDelegateHelper : NSObject <FUIAuthSignInUIDelegate>

- (instancetype)init NS_UNAVAILABLE;

/** @fn initWithUIDelegate:
    @brief Designated initializer
    @param delegate The UI delegate object which methods are verified.
 */
- (instancetype)initWithUIDelegate:(id<FUIAuthSignInUIDelegate>)delegate NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
