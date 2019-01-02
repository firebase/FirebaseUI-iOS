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

#import <UIKit/UIKit.h>

@protocol FUIAuthProvider;

NS_ASSUME_NONNULL_BEGIN

/** @class FUIAuthSignInButton
    @brief Button representing an identity provider on the auth picker screen that starts
        authentication with the provider when touched.
 */
@interface FUIAuthSignInButton : UIButton

/** @property provider
    @brief The provider UI instance associated with this button. Can be nil.
 */
@property(nonatomic, strong, readonly, nullable) id<FUIAuthProvider> providerUI;

/** @fn initWithFrame:
    @brief Please use initWithFrame:image:text:backgroundColor:textColor:.
 */
- (id)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

/** @fn initWithCoder:
    @brief Please use initWithFrame:image:text:backgroundColor:textColor:.
 */
- (id)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

/** @fn initWithFrame:image:text:backgroundColor:textColor:
    @brief Designated initializer.
    @param frame The initial frame for the button.
    @param image Logo image for the button.
    @param text Button text.
    @param backgroundColor Background color of the button in the normal state.
    @param textColor Color of the button text.
 */
- (id)initWithFrame:(CGRect)frame
              image:(UIImage *)image
               text:(NSString *)text
    backgroundColor:(UIColor *)backgroundColor
          textColor:(UIColor *)textColor NS_DESIGNATED_INITIALIZER;

/** @fn initWithFrame:providerUI:
    @brief Convenience initalizer.
    @param frame The initial frame for the button.
    @param providerUI The provider UI instance associated with this button.
 */
- (id)initWithFrame:(CGRect)frame providerUI:(id<FUIAuthProvider>)providerUI;

@end

NS_ASSUME_NONNULL_END
