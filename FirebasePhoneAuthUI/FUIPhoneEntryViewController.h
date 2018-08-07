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

#import "FirebaseAuthUI.h"

@class FUICountryCodes;

NS_ASSUME_NONNULL_BEGIN

@interface FUIPhoneEntryViewController : FUIAuthBaseViewController

/** @fn initWithNibName:bundle:authUI:
    @brief Designated initializer.
    @param nibNameOrNil The name of the nib file to associate with the view controller.
    @param nibBundleOrNil The bundle in which to search for the nib file.
    @param authUI The @c FUIAuth instance that manages this view controller.
 */
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil
                         authUI:(FUIAuth *)authUI
__attribute__((deprecated("This is deprecated API and will be removed in a future release."
                          "Please use initWithNibName:bundle:authUI:phoneNumber:")));

/** @fn initWithAuthUI:
    @brief Convenience initializer.
    @param authUI The @c FUIAuth instance that manages this view controller.
 */
- (instancetype)initWithAuthUI:(FUIAuth *)authUI
__attribute__((deprecated("This is deprecated API and will be removed in a future release."
                          "Please use initWithNibName:bundle:authUI:phoneNumber:")));

/** @fn initWithAuthUI:phoneNumber:countryCodes:
    @brief Convenience initializer.
    @param authUI The @c FUIAuth instance that manages this view controller.
    @param phoneNumber The phone number which is being verifying.
    @param countryCodes Available country codes For the view controller to use. If the argument is
                        nil, the default @c FUICountryCodes will be used.
 */
- (instancetype)initWithAuthUI:(FUIAuth *)authUI
                   phoneNumber:(nullable NSString *)phoneNumber
                  countryCodes:(nullable FUICountryCodes *)countryCodes;

/** @fn initWithNibName:bundle:authUI:phoneNumber:countryCodes:
    @brief Designated initializer.
    @param nibNameOrNil The name of the nib file to associate with the view controller.
    @param nibBundleOrNil The bundle in which to search for the nib file.
    @param authUI The @c FUIAuth instance that manages this view controller.
    @param phoneNumber The phone number which is being verifying.
    @param countryCodes Available country codes For the view controller to use.  If the argument is
                        nil, the default @c FUICountryCodes will be used.
 */
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil
                         authUI:(FUIAuth *)authUI
                    phoneNumber:(nullable NSString *)phoneNumber
                   countryCodes:(nullable FUICountryCodes *)countryCodes NS_DESIGNATED_INITIALIZER;
@end

NS_ASSUME_NONNULL_END
