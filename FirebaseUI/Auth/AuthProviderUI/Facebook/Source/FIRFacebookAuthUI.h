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

#import <Foundation/Foundation.h>

#import "FIRAuthProviderUI.h"

NS_ASSUME_NONNULL_BEGIN

/** @class FIRFacebookAuthUI
    @brief AuthUI components for Facebook Login.
 */
@interface FIRFacebookAuthUI : NSObject <FIRAuthProviderUI>

/** @property appId
    @brief The Facebook App ID.
 */
@property(nonatomic, copy, readonly) NSString *appID;

/** @property scopes
    @brief The scopes to use with Facebook Login.
    @remarks Defaults to using "email" scopes.
 */
@property(nonatomic, copy) NSArray<NSString *> *scopes;

/** @fn init
    @brief Please use initWithAppId:
 */
- (nullable instancetype)init NS_UNAVAILABLE;

/** @fn initWithAppID:
    @brief Designated initializer.
    @param appId The Facebook App ID.
 */
- (nullable instancetype)initWithAppID:(NSString *)appID NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
