//
//  Copyright (c) 2019 Google Inc.
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

/** @class FUIOAuth
    @brief AuthUI components for OAuth Sign In.
 */
@interface FUIOAuth : NSObject <FUIAuthProvider>

/** @fn init
    @brief Please use `initWithAuthUI:providerID:providerName:buttonColor:iconImage:scopes:
        customParameters:` instead.
 */
- (instancetype)init NS_UNAVAILABLE;

/** @fn init
    @brief Please use `initWithAuthUI:providerID:providerName:buttonColor:iconImage:scopes:
        customParameters:` instead.
 */
- (instancetype)initWithAuthUI:(FUIAuth *)authUI NS_UNAVAILABLE;

/** @fn initWithAuthUI:providerID:buttonLabelText:buttonColor:iconImage:scopes:customParameters:
    @brief AuthUI components for OAuth Sign In.
    @param authUI The @c FUIAuth instance that manages controllers of this provider.
    @param providerID The unique identifier for the provider.
    @param buttonLabelText The text label for the sign in button.
    @param shortName A short display name for the provider.
    @param buttonColor The background color that should be used for the sign in button of the
        provider.
    @param iconImage The icon image of the provider.
    @param scopes Array used to configure the OAuth scopes.
    @param customParameters Dictionary used to configure the OAuth custom parameters.
 */
- (instancetype)initWithAuthUI:(FUIAuth *)authUI
                    providerID:(NSString *)providerID
               buttonLabelText:(NSString *)buttonLabelText
                     shortName:(NSString *)shortName
                   buttonColor:(UIColor *)buttonColor
                     iconImage:(UIImage *)iconImage
                        scopes:(nullable NSArray<NSString *> *)scopes
              customParameters:(nullable NSDictionary<NSString *, NSString*> *)customParameters
    NS_DESIGNATED_INITIALIZER;

/** @fn providerID:buttonLabelText:buttonColor:iconImage:scopes:customParameters:
    @brief Initialize the class instance with the default AuthUI.

    @param providerID The unique identifier for the provider.
    @param buttonLabelText The text label for the sign in button.
    @param shortName A short display name for the provider.
    @param buttonColor The background color that should be used for the sign in button of the
        provider.
    @param iconImage The icon image of the provider.
    @param scopes Array used to configure the OAuth scopes.
    @param customParameters Dictionary used to configure the OAuth custom parameters.
 */
- (instancetype)initWithProviderID:(NSString *)providerID
                   buttonLabelText:(NSString *)buttonLabelText
                         shortName:(NSString *)shortName
                       buttonColor:(UIColor *)buttonColor
                         iconImage:(UIImage *)iconImage
                            scopes:(nullable NSArray<NSString *> *)scopes
                  customParameters:(nullable NSDictionary<NSString *, NSString*> *)customParameters;

@end

NS_ASSUME_NONNULL_END
