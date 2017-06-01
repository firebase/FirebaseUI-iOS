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

@class FIRAuth;
@class FUIAuth;
@protocol FUIAuthProvider;

NS_ASSUME_NONNULL_BEGIN

/** @class FUIAuthBaseViewController
    @brief The base view controller that provides common methods for all subclasses.
 */
@interface FUIAuthBaseViewController : UIViewController

/** @property auth
    @brief The @c FIRAuth instance of the application.
 */
@property(nonatomic, strong, readonly) FIRAuth *auth;

/** @property authUI
    @brief The @c FUIAuth instance of the application.
 */
@property(nonatomic, strong, readonly) FUIAuth *authUI;

/** @fn init
    @brief Please use @c initWithNibName:bundle:authUI:.
 */
- (instancetype)init NS_UNAVAILABLE;

/** @fn initWithStyle:
    @brief Please use @c initWithNibName:bundle:authUI:.
 */
- (instancetype)initWithStyle:(UITableViewStyle)style NS_UNAVAILABLE;

/** @fn initWithNibName:bundle:
    @brief Please use @c initWithNibName:bundle:authUI:.
 */
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

/** @fn initWithNibName:bundle:authUI:
    @brief Designated initializer.
    @param nibNameOrNil The name of the nib file to associate with the view controller.
    @param nibBundleOrNil The bundle in which to search for the nib file.
    @param authUI The @c FUIAuth instance that manages this view controller.
 */
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil
                         authUI:(FUIAuth *)authUI NS_DESIGNATED_INITIALIZER;

/** @fn initWithAuthUI:
    @brief Convenience initializer.
    @param authUI The @c FUIAuth instance that manages this view controller.
 */
- (instancetype)initWithAuthUI:(FUIAuth *)authUI;

/** @fn onBack
    @brief Pops the view controller from navigation stack. If current controller is root 
    works as @c cancelAuthorization
 */
- (void)onBack;

/** @fn cancelAuthorization
    @brief Cancels Authorization flow, calls UI delegate callbacks and hides UI
 */
- (void)cancelAuthorization;

@end

NS_ASSUME_NONNULL_END
